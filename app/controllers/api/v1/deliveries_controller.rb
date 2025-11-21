module Api
  module V1
    class DeliveriesController < Api::V1::BaseController
      before_action :authenticate_user_from_token!
      before_action :set_delivery, only: [ :update ]

      def index
        courier = current_user
        courier_address = courier.address

        deliveries = Delivery.includes(:order)

        render json: deliveries.map { |delivery|
          product_value = delivery.order.total
          delivery_address = delivery.delivery_address

          result = DeliveryPriceCalculatorService.new(
            courier_address: courier_address,
            delivery_address: delivery_address,
            product_value: product_value
          ).calculate

          delivery.as_json.merge({
            intended_price: result[:price],
            estimated_distance_in_km: result[:distance_km]
          })
        }, status: :ok
      end

      def update
        if params[:deliveries][:estimated_distance_in_km].to_i > 50
          return render json: { error: "Estimated distance exceeds the maximum allowed limit." }, status: :unprocessable_entity
        end

        old_status = @delivery.status

        if @delivery.update(delivery_params)
          @delivery.update(courier_id: current_user.id)

          if params[:deliveries][:status] == "picked_up"
            @delivery.update(picked_up_at: Time.current)
            Order.find(@delivery.order_id).update(delivery_status: :picked_up)
          elsif params[:deliveries][:status] == "on_route"
            @delivery.update(status: :on_route)
            Order.find(@delivery.order_id).update(delivery_status: :on_route)
          elsif params[:deliveries][:status] == "delivered"
            @delivery.update(delivered_at: Time.current, status: :delivered)
            Order.find(@delivery.order_id).update(delivery_status: :delivered)
          elsif params[:deliveries][:status] == "returned"
            @delivery.update(status: :returned)
            Order.find(@delivery.order_id).update(delivery_status: :returned)
          elsif params[:deliveries][:status] == "canceled"
            @delivery.update(status: :canceled)
            Order.find(@delivery.order_id).update(delivery_status: :canceled)
          end

          if old_status != @delivery.status
            customer = User.find(@delivery.customer_id)
            DeliveryMailer.with(customer: customer, delivery: @delivery).status_updated.deliver_later
          end

          render json: @delivery, status: :ok
        else
          render json: { errors: @delivery.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def my_deliveries
        courier = current_user

        deliveries = Delivery.where(courier_id: courier.id)

        render json: deliveries.map { |delivery|
          customer = User.find(delivery.customer_id)

          delivery.as_json.merge({
            customer: {
              id: customer.id,
              full_name: customer.full_name
            }
          })
        }, status: :ok
      end



      private

      def set_delivery
        @delivery = Delivery.find(params[:id])
      end

      def delivery_params
        params.require(:deliveries).permit(:status)
      end
    end
  end
end
