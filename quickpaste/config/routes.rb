Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pastes#index"

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  post "/auth/magic_link", to: "sessions#create", as: :magic_link
  post "/auth/magic_link/resend", to: "sessions#resend_magic_link", as: :magic_link_resend
  get "/auth/magic", to: "sessions#magic", as: :auth_magic
  delete "/logout", to: "sessions#destroy", as: :logout

  resources :pastes do
    collection do
      get :mine
    end
    member do
      post :confirm_read_once
      post :unlock
      get :manage
    end
  end

  resources :notices, only: %i[show new create edit update destroy]
end
