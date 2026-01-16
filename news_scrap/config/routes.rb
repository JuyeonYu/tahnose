Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :keywords do
    member do
      patch :toggle_alarm
    end
  end

end
