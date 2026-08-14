Rails.application.routes.draw do
  root to: proc { [200, { "Content-Type" => "application/json" }, [{ status: "online", message: "AutoPass API Server is running" }.to_json]] }
  # Removed: an unauthenticated "debug_admin" route that returned every
  # AdminUser's id, e-mail and role as JSON, in every environment — a
  # ready-made target list for the ActiveAdmin login, which has no Devise
  # :lockable. Use `rails console` or the admin UI instead.

  mount ActionCable.server => "/cable"
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get "up" => "rails/health#show", as: :rails_health_check
  get "/favicon.ico", to: redirect("/admin_logo.png")

  # Public QR-verification landing page (no login) — scanned from the
  # "QR CODE ເອກະສານ" feature in the app.
  get "verify/:token", to: "verifications#show", as: :verification, constraints: { token: /.+/ }
  get "verify_report/:token", to: "verifications#report", as: :verification_report, constraints: { token: /.+/ }

  namespace :api do
    namespace :v1 do
      # Auth
      post "auth/request_otp"
      # Debug GET endpoint for manual testing (only enabled when ALLOW_DEBUG env var is 'true')
      get  "auth/request_otp_debug", to: "auth#request_otp_debug"
      post "auth/verify_otp"
      get  "auth/me"
      post "auth/register_device"
      post "auth/login_phone"
      put  "auth/profile"
      post "auth/verify_token"

      # Vehicles
      resources :vehicles do
        member do
          post "share"
          delete "share/:user_id", action: :unshare, as: :unshare
          post "pay_fee"
        end
      end
      resources :vehicle_fee_rates, only: %i[index]

      # Road Tax
      resources :road_taxes, only: %i[index create show]
      resources :road_tax_rates, only: %i[index]
      resource :road_tax_setting, only: %i[show]

      # Insurance
      resources :insurances, only: %i[index create show] do
        member do
          patch :upload_document
          get :certificate
        end
      end

      # Inspection
      resources :inspections, only: %i[index create show update]

      # Transactions
      resources :transactions, only: %i[index show]

      # Payments (BCEL OnePay) — poll-for-status; creation happens inside
      # each payable's own create action.
      resources :payments, only: %i[show], param: :id

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
      resources :partner_applications, only: %i[create]

      # Vehicle Brands
      get "vehicle_brands", to: "vehicle_brands#index"

      # Plate Types (public reference data)
      get "plate_types", to: "plate_types#index"

      # OCR
      post "ocr/scan", to: "ocr#scan"

      # Onboarding
      get "onboarding_slides", to: "onboarding_slides#index"

      # Advertisements / promo banners
      get "advertisements", to: "advertisements#index"
      post "advertisements/:id/click", to: "advertisements#click"

      # Hotline support chat
      resources :chat_messages, only: %i[index create]
      get "support_case", to: "support_cases#show"
      post "support_case/rate", to: "support_cases#rate"

      # Announcements
      get "announcements", to: "announcements#index"
      post "announcements/mark_seen", to: "announcements#mark_seen"
      get "announcements/:id", to: "announcements#show"
    end
  end
end
