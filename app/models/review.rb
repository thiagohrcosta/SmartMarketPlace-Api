class Review < ApplicationRecord
  belongs_to :user
  belongs_to :order
  belongs_to :company

  enum kind: {
    general_feedback: 0,
    scam: 1,
    fraud: 2,
    spam: 3,
    offensive: 4,
    delivery_issue: 5,
    other: 6
  }
end
