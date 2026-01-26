Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  get "/auth/magic", to: "sessions#magic", as: :auth_magic
  delete "/logout", to: "sessions#destroy", as: :logout

  resources :pastes do
    member do
      post :unlock
      get :manage
    end
  end
end
