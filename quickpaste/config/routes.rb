Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :pastes do
    member do
      post :unlock
      get :manage
    end
  end
end
