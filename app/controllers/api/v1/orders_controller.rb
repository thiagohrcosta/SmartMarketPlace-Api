module Api
  module V1
    class OrdersController < Api::V1::BaseController
      before_action :authenticate_user_from_token!, only: [ :index, :show, :create ]
      before_action :set_order, only: [ :show ]

      def index
        @orders = Order.where(user_id: current_user.id)

        render json: { orders: formatted_orders(@orders) }
      end

      def show
        render json: { order: formatted_order(@order) }
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

        render json: {
          order_id: @order.id,
          total: total_price,
          product_order: @order.product_orders.map do |prod|
            prod.as_json(except: [ :created_at, :updated_at ]).merge(
              product: prod.product.as_json(except: [ :stock, :created_at, :updated_at, :age_restricted ])
            )
          end
        }, status: :ok
      end

      private

      def set_order
        @order = Order.find(params[:id])
      end

      def formatted_orders(orders)
        orders.map { |order| formatted_order(order) }
      end

      def formatted_order(order)
        {
          order: order.as_json(except: [ :created_at, :updated_at ]),
          product_orders: order.product_orders.as_json(except: [ :created_at, :updated_at ]),
          products: order.product_orders.map do |po|
            po.product.as_json(except: [ :stock, :created_at, :updated_at, :age_restricted ]).merge(
              company_name: po.product.company&.name
            )
          end,
          payment: order.payment&.as_json(except: [ :created_at, :updated_at, :payload ])
        }
      end
    end
  end
end
