module Api
  module V1
    class OrdersController < ApplicationController
      def create
        @order = Order.find_or_create_by(user_id: params[:user_id], is_active: true)

        @order.product_orders.destroy_all

        total_price = 0

        params[:products].each do |product_data|
          product = Product.find(product_data[:id])
          amount = product_data[:amount].to_i

          @order.product_orders.create!(
            product: product,
            amount: amount
          )

          total_price += product.price * amount
        end

        @order.update!(total: total_price)

        render json: {
          order_id: @order.id,
          total: total_price,
          product_order: @order.product_orders.map do |prod|
            prod.as_json(except: [:created_at, :updated_at]).merge(
              product: prod.product.as_json(except: [:stock, :created_at, :updated_at, :age_restricted ])
            )
          end
        }, status: :ok
      end
    end
  end
end
