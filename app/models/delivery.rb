class Delivery < ApplicationRecord
  belongs_to :order

  enum status: {
    waiting_payment: "waiting_payment",
    pending_pickup: "pending_pickup",
    picked_up: "picked_up",
    on_route: "on_route",
    delivered: "delivered",
    returned: "returned",
    canceled: "canceled"
  }
end
