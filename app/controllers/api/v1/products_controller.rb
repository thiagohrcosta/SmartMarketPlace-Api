module Api
  module V1
    class ProductsController < Api::V1::BaseController
      before_action :authenticate_user_from_token!
      before_action :set_company, only: [ :create, :update ]
      before_action :check_user_company, only: [ :create, :update ]
      before_action :set_product, only: [ :show, :update ]
      before_action :product_agent_checker, only: [ :create, :update ]

      def index
        products = Product.all

        render json: {
          products: products.map { |product| ProductFormatter.new(product).call }
        }, status: :ok
      end

      def show
        render json: ProductFormatter.new(@product).call, status: :ok
      end

      def create
        return if company_blocked(@company)

        if params[:product][:status].present?
          params[:product][:status] = params[:product][:status].to_i
        end

        product = current_user.company.products.build(product_params)

        if product.save
          render json: ProductFormatter.new(product).call, status: :created
        else
          render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
        end
      end


      def update
        if @product.update(product_params)
          render json: ProductFormatter.new(@product).call, status: :ok
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # Soft delete
      def delete_product
        @product = Product.find(params[:product][:product_id])
        if @product.update(status: "deleted")
          render status: :ok
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def company_blocked(company)
        if !company.is_active
          render json: { errors: "Company is blocked and cannot create or edit products. Contact your support." }, status: :forbidden
          return true
        end
        false
      end

      def product_json(product)
        {
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price,
          age_restricted: product.age_restricted,
          status: product.status,
          stock: product.stock,
          photos: product.photos.map { |photo| url_for(photo) }
        }
      end

      def check_user_company
        if !current_user.company.present?
          render json: { errors: "User can't create or edit products" }, status: :unprocessable_entity
          nil
        end
      end

      def set_product
        @product = Product.find(params[:id])
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
          :company_id,
          photos: []
        )
      end
    end
  end
end
