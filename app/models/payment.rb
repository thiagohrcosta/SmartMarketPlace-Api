class Payment < ApplicationRecord
  belongs_to :order
  belongs_to :user

  validates :order_id, presence: true
  validates :user_id, presence: true

  enum payment_method: {
    credit_card: 0
  }

  enum status: {
    pending: 0,
    paid: 1,
    cancelled: 2
  }
end
