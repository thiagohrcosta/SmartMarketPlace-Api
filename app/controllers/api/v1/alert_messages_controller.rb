module Api
  module V1
    class AlertMessagesController < Api::V1::BaseController
      before_action :authenticate_user_from_token!
      before_action :user_is_admin?

      def index
        @alert_messages = AlertMessage.all
        render json: @alert_messages, status: :ok
      end
    end
  end
end
