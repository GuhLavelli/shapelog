Rails.application.routes.draw do
  resource  :session
  resources :passwords, param: :token

  root "dashboard#index"
  get "dashboard", to: "dashboard#index"

  resources :daily_checkins
  resources :mounjaro_applications
  resources :body_measurements
  resources :weights, only: :index
  resource  :goal, only: [:show, :edit, :update]

  get "up" => "rails/health#show", as: :rails_health_check
end
