Rails.application.config.to_prepare do
  unless ActiveAdmin::BaseController.include?(PartnerAccessControl)
    ActiveAdmin::BaseController.include(PartnerAccessControl)
  end

  # Send partners to their own (scoped) Dashboard on login. Redefining a
  # method is idempotent, so no extra guard is needed against this block
  # re-running on reload.
  ActiveAdmin::Devise::SessionsController.class_eval do
    def after_sign_in_path_for(resource)
      resource.respond_to?(:partner?) && resource.partner? ? admin_dashboard_path : super
    end
  end
end
