Rails.application.config.to_prepare do
  unless ActiveAdmin::BaseController.include?(PartnerAccessControl)
    ActiveAdmin::BaseController.include(PartnerAccessControl)
  end

  unless ActiveAdmin::BaseController.include?(ActivityLogging)
    ActiveAdmin::BaseController.include(ActivityLogging)
  end

  unless ActiveAdmin::BaseController.include?(InsuranceAccessControl)
    ActiveAdmin::BaseController.include(InsuranceAccessControl)
  end

  unless ActiveAdmin::BaseController.include?(ServicePartnerAccessControl)
    ActiveAdmin::BaseController.include(ServicePartnerAccessControl)
  end

  unless ActiveAdmin::BaseController.include?(RolePermissionAccessControl)
    ActiveAdmin::BaseController.include(RolePermissionAccessControl)
  end

  # Send partners to their own (scoped) Dashboard on login. Redefining a
  # method is idempotent, so no extra guard is needed against this block
  # re-running on reload.
  ActiveAdmin::Devise::SessionsController.class_eval do
    def after_sign_in_path_for(resource)
      if resource.respond_to?(:partner?) && resource.partner?
        admin_dashboard_path
      elsif resource.respond_to?(:service_partner?) && resource.service_partner?
        admin_service_center_overview_path(type: resource.service_center.service_type)
      else
        super
      end
    end
  end
end
