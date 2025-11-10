module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user_from_token!

      private

      def product_agent_checker
        product_agent = ProductAgentService.new(product_params, current_user).call

        unless product_agent["approved"]
          render json: { error: product_agent["message"] }, status: :unprocessable_entity
          return
        end
      end

      def authenticate_user_from_token!
        header = request.headers['Authorization']
        token = header.split(' ').last if header.present?
        decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
        @current_user = User.find(decoded["id"])
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: 'Not authorized' }, status: :unauthorized
      end

      def current_user
        @current_user
      end
    end
  end
end
