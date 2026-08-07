# Included into ActiveAdmin::BaseController (see
# config/initializers/partner_access_control.rb). A partner-role
# admin_user only ever gets full access to their own bookings and their
# own inspection center — hiding menu links isn't real authorization, so
# this blocks direct URL access to every other admin resource too.
module PartnerAccessControl
  extend ActiveSupport::Concern

  ALLOWED_PARTNER_CONTROLLERS = %w[admin/inspections admin/inspection_centers admin/dashboard admin/reports].freeze

  included do
    before_action :restrict_partner_scope
  end

  private

  def restrict_partner_scope
    return unless current_admin_user&.partner?
    return if ALLOWED_PARTNER_CONTROLLERS.include?(controller_path)

    redirect_to admin_inspections_path, alert: "ທ່ານບໍ່ມີສິດເຂົ້າເຖິງໜ້ານີ້"
  end
end
