# Included into ActiveAdmin::BaseController (see
# config/initializers/partner_access_control.rb). A "staff" role admin_user
# is granted access only to the resources their assigned Role has
# permissions for, and only for the specific actions (read/create/update/
# delete) that role was given — enforced server-side, not just by hiding
# sidebar links. Plain "admin" and "superadmin" accounts are completely
# unaffected (see AdminUser#unrestricted?).
module RolePermissionAccessControl
  extend ActiveSupport::Concern

  included do
    before_action :enforce_role_permission
  end

  private

  def enforce_role_permission
    return unless current_admin_user&.staff?
    return if controller_path == "admin/dashboard" # always-reachable landing page / redirect target

    resource_key = controller_path.sub(%r{\Aadmin/}, "")
    required = required_permission_action
    allowed = required && current_admin_user.custom_role&.can?(resource_key, required)

    return if allowed

    redirect_to admin_dashboard_path, alert: "ທ່ານບໍ່ມີສິດເຂົ້າເຖິງໜ້ານີ້"
  end

  def required_permission_action
    case action_name
    when "index", "show" then :read
    when "new", "create" then :create
    when "edit", "update" then :update
    when "destroy" then :delete
    else :read # page_actions / custom member actions default to a read-gate
    end
  end
end
