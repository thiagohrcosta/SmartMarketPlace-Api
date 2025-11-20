module Api
  module V1
    class AlertMessagesController < Api::V1::BaseController
      before_action :authenticate_user_from_token!
      before_action :user_is_admin?, except: [ :my_alerts, :show, :update ]
      before_action :set_company, only: [ :my_alerts ]
      before_action :set_alert_message, only: [ :show, :update ]

      def index
        @alert_messages = AlertMessage.all
        render json: AlertMessageFormatter.new(@alert_messages).call, status: :ok
      end

      def show
        if user_can_view_or_edit?
          render json: AlertMessageFormatter.new(@alert_message).call, status: :ok
        else
          render json: { error: "Forbidden" }, status: :forbidden
        end
      end

      def update
        if user_can_view_or_edit?
          if @alert_message.update(alert_message_params)
            render json: AlertMessageFormatter.new(@alert_message).call, status: :ok
          else
            render json: { errors: @alert_message.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: "Forbidden" }, status: :forbidden
        end
      end

      def my_alerts
        products = Product.where(company_id: @company.id).pluck(:id)
        @alert_messages = AlertMessage.where(product_id: products)
        render json:  AlertMessageFormatter.new(@alert_messages), status: :ok
      end

      private

      def user_can_view_or_edit?
        @alert_message.product.company.user_id == current_user.id
      end

      def set_alert_message
        @alert_message = AlertMessage.find(params[:id])
      end

      def set_company
        @company = Company.find(current_user.company.id)
      end

      def alert_message_params
        params.require(:alert_message).permit(:read)
      end
    end
  end
end
