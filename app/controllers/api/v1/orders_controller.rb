module Api
  module V1
    class OrdersController < Api::V1::BaseController
      before_action :authenticate_user_from_token!, only: [ :index, :show, :create ]
      before_action :set_order, only: [ :show ]

      def index
        @orders = Order.where(user_id: current_user.id)

        render json: { orders: OrderCollectionFormatter.new(@orders).call }
      end

      def show
        render json: { order: OrderFormatter.new(@order).call }
      end

      def create
        @order = Order.find_or_create_by(user_id: current_user.id, is_active: true)

        @order.product_orders.destroy_all

        total_price = 0

        params[:products].each do |product_data|
          product = Product.find(product_data[:id])
          amount = product_data[:amount].to_i

          @order.product_orders.create!(
            product: product,
            amount: amount
          )

          total_price += product.price.to_f * amount
        end

        @order.update!(total: total_price)

        render json: OrderFormatter.new(@order).call, status: :ok
      end

      private

      def set_order
        @order = Order.find(params[:id])
      end
    end
  end
end
