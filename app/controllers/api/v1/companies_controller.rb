module Api
  module V1
    class CompaniesController < Api::V1::BaseController
      before_action :authenticate_user_from_token!, except: [ :index, :show ]
      before_action :set_company, only: [ :update, :show ]

      def index
        companies = Company.all
        render json: companies, status: :ok
      end

      def show
        render json: @company, status: :ok
      end

      def create
        return if user_already_has_one_company

        company = current_user.build_company(company_params)

        if company.save
          render json: company, status: :created
        else
          render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        user_is_allowed_to_edit

        if @company.update(company_params)
          render json: @company, status: 200
        else
          render json: { errors: @company.erros.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_already_has_one_company
        return unless Company.exists?(user_id: current_user.id)

        render json: { errors: "User already has one company created." }, status: :unprocessable_entity
      end

      def user_is_allowed_to_edit
        if @company.user_id != current_user.id
          render json: { errors: "Not authorized" }, status: :unauthorized
          nil
        end
      end

      def set_company
        @company = Company.find(params[:id])
      end

      def company_params
        params.require(:company).permit(:name, :description)
      end
    end
  end
end
