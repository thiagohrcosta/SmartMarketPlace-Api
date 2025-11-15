Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  namespace :api do
    namespace :v1 do
      devise_for :users,
                 path: "",
                 path_names: {
                   sign_in: "login",
                   sign_out: "logout",
                   registration: "users"
                 },
                 controllers: {
                   sessions: "api/v1/users/sessions",
                   registrations: "api/v1/users/registrations"
                 }

      get "/me", to: "users#me"
      post "stripe/webhook", to: "stripe_webhooks#create"

      resources :companies, only: [ :index, :show, :create, :update ]
      resources :products do
        patch "delete", to: "products#delete_product", as: :delete_product
      end

      resources :orders, only: [ :index, :show, :create ]
      resources :payments, only: [ :create ]
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
