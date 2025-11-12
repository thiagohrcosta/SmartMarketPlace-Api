module Stripe
  class PaymentService
    def initialize(order)
      @order = order
      Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    end

    def create_payment_intent
      Stripe::PaymentIntent.create(
        amount: @order.total.to_i,
        currency: 'usd',
        confirm: true,
        metadata: {
          order_id: @order.id,
          user_id: @order.user_id
        }
      )
    rescue Stripe::StripeError => e
      Rails.logger.error("Stripe error: #{e.message}")
      raise e
    end
  end
end
