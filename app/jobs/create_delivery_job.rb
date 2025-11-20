class CreateDeliveryJob < ApplicationJob
  queue_as :default

  def perform
    recent_orders = Order.where("created_at >= ?", 12.hours.ago)
                         .where(delivery_status: 0)

    recent_orders.each do |order|
      next if Delivery.exists?(order_id: order.id, customer_id: order.user_id)

      order_status = order.payment&.status == "paid" ? "pending_pickup" : "waiting_payment"
      formatted_address = format_address(order.user.address)

      Delivery.create!(
        order_id: order.id,
        status: order_status,
        customer_id: order.user_id,
        delivery_address: formatted_address
      )
    end
  end

  private

  def format_address(address_hash)
    return "" unless address_hash.present?

    street = address_hash["street"] || address_hash[:street]
    city   = address_hash["city"]   || address_hash[:city]
    state  = address_hash["state"]  || address_hash[:state]
    zip    = address_hash["zip"]    || address_hash[:zip]

    [ street, city, state, zip ].compact.join(", ")
  end
end
