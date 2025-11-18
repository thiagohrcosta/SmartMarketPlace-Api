module Api
  module V1
    class PaymentsController <  Api::V1::BaseController
      def create
        @order = Order.find(params[:payment][:order_id])

        return unless check_if_there_is_opened_payment(@order)

        unless @order.user_id == current_user.id
          return render json: { error: "Unauthorized" }, status: :unauthorized
        end

        @payment = Payment.create!(
          order: @order,
          user: current_user,
          payment_method: 0,
          status: 0
        )

        session = Stripe::Checkout::Session.create(
          payment_method_types: [ "card" ],
          line_items: [
            {
              price_data: {
                currency: "usd",
                product_data: {
                  name: "Order ##{@order.id}"
                },
                unit_amount: @order.total.to_i
              },
              quantity: 1
            }
          ],
          mode: "payment",
          success_url: "http://localhost:3001/payment/success?session_id={CHECKOUT_SESSION_ID}",
          cancel_url: "http://localhost:3001/payment/cancel",
          metadata: {
            order_id: @order.id,
            user_id: current_user.id
          }
        )

        @payment.update!(payload: session.to_json)

        render json: {
          order_id: @order.id,
          checkout_url: session.url
        }, status: :ok
      rescue StandardError => e
        Rails.logger.error("Payment creation failed: #{e.message}")
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def check_if_there_is_opened_payment(order)
        if order.payment.present?
          render json: { error: "Can't create multiple invoices for the same order" }, status: :unprocessable_entity
          return false
        end
        true
      end
    end
  end
end
