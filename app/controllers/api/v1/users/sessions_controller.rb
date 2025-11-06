module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        respond_to :json

        def create
          user = User.find_for_database_authentication(email: params[:user][:email])
          if user && user.valid_password?(params[:user][:password])
            token = user.generate_jwt
            render json: { token: token, user: { id: user.id, email: user.email } }, status: :ok
          else
            render json: { error: 'Email ou senha inválidos' }, status: :unauthorized
          end
        end
      end
    end
  end
end
