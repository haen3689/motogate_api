Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get "up" => "rails/health#show", as: :rails_health_check
  get "/favicon.ico", to: redirect("/admin_logo.png")

  namespace :api do
    namespace :v1 do
      # Auth
      post "auth/request_otp"
      post "auth/verify_otp"
      get  "auth/me"
      post "auth/register_device"
      post "auth/login_phone"
      put  "auth/profile"

      # Vehicles
      resources :vehicles

      # Road Tax
      resources :road_taxes, only: %i[index create show]

      # Insurance
      resources :insurances, only: %i[index create show]

      # Inspection
      resources :inspections, only: %i[index create show update]

      # Transactions
      resources :transactions, only: %i[index show]

      # Notifications
      resources :notifications, only: %i[index] do
        member { patch :mark_read }
        collection { patch :mark_all_read }
      end

      # Inspection Centers
      resources :inspection_centers, only: %i[index show]

      # Insurance Companies
      resources :insurance_companies, only: %i[index show]

      # Service Centers (garage / towing / dealer)
      resources :service_centers, only: %i[index show]

      # Vehicle Brands
      get "vehicle_brands", to: "vehicle_brands#index"

      # Plate Types (public reference data)
      get "plate_types", to: "plate_types#index"

      # OCR
      post "ocr/scan", to: "ocr#scan"

      # Onboarding
      get "onboarding_slides", to: "onboarding_slides#index"
    end
  end
end
