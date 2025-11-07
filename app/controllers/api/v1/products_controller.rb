module Api
  module V1
    class ProductsController < Api::V1::BaseController
      before_action :authenticate_user_from_token!
      before_action :set_company, only: [:create, :update]
      before_action :check_user_company, only: [:create, :update]

      def index
        products = Product.all
        render json: { products: products }, status: :ok
      end

      def create
        ProductAgentService.new(product_params, current_user).call
        product_agent = ProductAgentService.new(product_params, current_user).call

        unless product_agent["approved"]
          render json: { error: product_agent["message"] }, status: :unprocessable_entity
          return
        end

        product = current_user.company.products.build(product_params)

        if product.save!
          render json: product, status: :created
        else
          render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update;end

      private

      def check_user_company
        if !current_user.company.present?
          render json: { errors: "User can't create or edit products" }, status: :unprocessable_entity
          return
        end
      end

      def set_product
      end

      def set_company
        @company = Company.find(params[:product][:company_id])
      end

      def product_params
        params.require(:product).permit(
          :name,
          :description,
          :price,
          :age_restricted,
          :status,
          :stock,
          :company_id
        )
      end
    end
  end
end
