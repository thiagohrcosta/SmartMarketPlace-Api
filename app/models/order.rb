class Order < ApplicationRecord
  has_many :product_orders, dependent: :destroy
  has_one :payment, dependent: :destroy

  enum delivery_status: {
    pending: 0,
    preparing: 1,
    shipped: 2,
    delivered: 3,
    cancelled: 4
  }
end
