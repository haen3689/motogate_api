# Included into ActiveAdmin::BaseController (see
# config/initializers/partner_access_control.rb). An insurance-role
# admin_user only ever gets full access to their own company's orders,
# their own company profile, dashboard and reports — hiding menu links
# isn't real authorization, so this blocks direct URL access to every
# other admin resource too. Mirrors PartnerAccessControl.
module InsuranceAccessControl
  extend ActiveSupport::Concern

  ALLOWED_INSURANCE_CONTROLLERS = %w[admin/insurances admin/insurance_companies admin/dashboard admin/reports].freeze

  included do
    before_action :restrict_insurance_scope
  end

  private

  def restrict_insurance_scope
    return unless current_admin_user&.insurance?
    return if ALLOWED_INSURANCE_CONTROLLERS.include?(controller_path)

    redirect_to admin_insurances_path, alert: "ທ່ານບໍ່ມີສິດເຂົ້າເຖິງໜ້ານີ້"
  end
end
