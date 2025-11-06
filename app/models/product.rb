class Product < ApplicationRecord
  belongs_to :company

  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true
  validates :age_restricted, inclusion: { in: [true, false] }
  validates :status, presence: true
  validates :stock, presence: true

  enum status: {
    available: 0,
    unavailable: 1,
    blocked: 2,
    suspended: 3
  }
end
