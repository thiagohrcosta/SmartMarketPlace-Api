class Company < ApplicationRecord
  belongs_to :user
  has_many :products, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
end
