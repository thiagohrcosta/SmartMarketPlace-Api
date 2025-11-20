class Order < ApplicationRecord
  belongs_to :user
  has_many :product_orders, dependent: :destroy
  has_one :payment, dependent: :destroy
  has_one :delivery, dependent: :destroy

  enum delivery_status: {
    waiting_payment: 0,
    pending_pickup: 1,
    picked_up: 2,
    on_route: 3,
    delivered: 4,
    returned: 5,
    canceled: 6
  }
end
