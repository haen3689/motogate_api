# Included into ActiveAdmin::BaseController (see
# config/initializers/partner_access_control.rb). A service_partner-role
# admin_user (garage/dealer/towing owner) only ever gets access to their
# own center's profile, contract/rent and revenue report — hiding menu
# links isn't real authorization, so this blocks direct URL access to
# every other admin resource too. Mirrors InsuranceAccessControl.
module ServicePartnerAccessControl
  extend ActiveSupport::Concern

  ALLOWED_SERVICE_PARTNER_CONTROLLERS = %w[
    admin/service_centers admin/service_center_contracts
    admin/service_center_overview admin/service_center_revenue_reports
    admin/dashboard
  ].freeze

  included do
    before_action :restrict_service_partner_scope
  end

  private

  def restrict_service_partner_scope
    return unless current_admin_user&.service_partner?
    return if ALLOWED_SERVICE_PARTNER_CONTROLLERS.include?(controller_path)

    redirect_to admin_service_center_overview_path(type: current_admin_user.service_center.service_type),
                alert: "ທ່ານບໍ່ມີສິດເຂົ້າເຖິງໜ້ານີ້"
  end
end
