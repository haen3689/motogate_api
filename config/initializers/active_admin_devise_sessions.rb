# Override ActiveAdmin Devise Sessions controller to use custom layout
Rails.application.config.to_prepare do
  ActiveAdmin::Devise::SessionsController.layout 'active_admin_logged_out'
end
