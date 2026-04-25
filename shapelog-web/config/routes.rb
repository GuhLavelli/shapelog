Rails.application.routes.draw do
  resource  :session
  resources :passwords, param: :token

  root "dashboard#index"
  get "dashboard", to: "dashboard#index"

  resources :daily_checkins
  resources :medication_options, only: :index
  resources :medications
  resources :weights, only: :index
  resource  :goal, only: [:show, :edit, :update]
  resources :alerts, except: :show

  get "up" => "rails/health#show", as: :rails_health_check
end
