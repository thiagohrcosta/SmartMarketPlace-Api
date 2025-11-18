module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        def create
          user = User.new(sign_up_params)
          if user.save
            render json: { status: "success", data: user }, status: :created
          else
            render json: { status: "error", errors: user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def sign_up_params
          params.require(:user).permit(
            :email, :password, :password_confirmation,
            :full_name, :birthday, :role,
            address: [ :street, :city, :state, :zip ]
          )
        end
      end
    end
  end
end
