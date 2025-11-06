class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  has_one :company, dependent: :destroy, foreign_key: :user_id

  enum role: {
    user: 0,
    support: 1,
    saller: 2,
    admin: 3
  }


  def generate_jwt
    JWT.encode(
      { id: id, exp: 60.days.from_now.to_i },
      Rails.application.credentials.secret_key_base
    )
  end
end
