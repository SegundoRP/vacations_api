Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      resources :time_off_requests, except: %i[new edit]
      resources :users, only: %i[index] do
        get :vacation_days, on: :member
      end
    end
  end
end
