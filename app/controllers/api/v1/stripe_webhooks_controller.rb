module Api
  module V1
    class StripeWebhooksController < Api::V1::BaseController
      skip_before_action :authenticate_user_from_token!

      def create
        puts request.body
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']

        webhook_secret = ENV['STRIPE_WEBHOOK_SECRET'] || Rails.application.credentials.dig(:stripe, :webhook_secret)

        unless webhook_secret.present?
          Rails.logger.error("Stripe webhook secret not found")
          return render json: { error: "Webhook secret not found" }, status: 500
        end

        begin
          event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
        rescue JSON::ParserError => e
          Rails.logger.error("Error to parse payload #{e.message}")
          return render json: { error: "Invalid payload" }, status: 400
        rescue Stripe::SignatureVerificationError => e
          Rails.logger.error("Stripe signature invalid: #{e.message}")
          return render json: { error: "Invalid signature" }, status: 400
        end

        case event['type']
        when 'checkout.session.completed'
          session = event['data']['object']
          handle_successful_checkout(session)
        when 'payment_intent.succeeded'
          intent = event['data']['object']
          handle_payment_succeeded(intent)
        else
          Rails.logger.info("Event #{event['type']}")
        end

        render json: { message: "success" }, status: 200
      end

      private

      def handle_successful_checkout(session)
        order_id = session['metadata']&.[]('order_id')

        unless order_id
          Rails.logger.warn("checkout.session.completed without order_id")
          return
        end

        payment = Payment.find_by(order_id: order_id)

        if payment
          payment.update!(
            status: 1,
            payload: session.to_json
          )
          Rails.logger.info("Order ##{order_id} paid")
        else
          Rails.logger.warn("Payment not found for order_id=#{order_id}")
        end
      end

      def handle_payment_succeeded(intent)
        Rails.logger.info("💳 PaymentIntent succeeded: #{intent['id']}")
      end
    end
  end
end
