module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user_from_token!

      private

      def product_agent_checker
        product_agent = ProductAgentService.new(product_params, current_user).call

        unless product_agent["approved"]
          render json: { error: product_agent["message"] }, status: :unprocessable_entity
          nil
        end
      end

      def authenticate_user_from_token!
        header = request.headers["Authorization"]
        token = header.split(" ").last if header.present?
        decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
        @current_user = User.find(decoded["id"])
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: "Not authorized" }, status: :unauthorized
      end

      def current_user
        @current_user
      end

      def user_is_admin?
        unless current_user&.admin?
          render json: { error: "Forbidden" }, status: :forbidden
        end
      end

      def is_company_user?
        unless current_user&.company_id == company_id
          render json: { error: "Forbidden" }, status: :forbidden
        end
      end
    end
  end
end
