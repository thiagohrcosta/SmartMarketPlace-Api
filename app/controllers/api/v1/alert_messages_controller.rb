module Api
  module V1
    class AlertMessagesController < Api::V1::BaseController
      before_action :authenticate_user_from_token!
      before_action :user_is_admin?, except: [ :my_alerts ]
      before_action :set_company, only: [ :my_alerts]

      def index
        @alert_messages = AlertMessage.all
        render json: AlertMessageFormatter.new(@alert_messages).call, status: :ok
      end

      def my_alerts
        products = Product.where(company_id: @company.id).pluck(:id)
        @alert_messages = AlertMessage.where(product_id: products)
        render json: @alert_messages, status: :ok
      end

      private

      def set_company
        @company = Company.find(current_user.company.id)
      end
    end
  end
end
