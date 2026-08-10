ActiveAdmin.register ServiceCenter do
  menu false

  permit_params :name, :location, :phone, :owner_name, :service_type, :specialty, :status, :rating, :lat, :lng, :logo_file

  config.filters = false
  config.batch_actions = false

  member_action :toggle_status, method: :post do
    resource.update!(status: resource.status == "active" ? "inactive" : "active")
    redirect_back fallback_location: admin_service_centers_path
  end

  index as: :content do
    render partial: "active_admin/service_centers_content"
  end

  show do
    render partial: "active_admin/service_center_show_content"
  end

  form partial: "active_admin/service_center_form_content"

  controller do
    before_action :redirect_service_partner_to_own_center, only: :index
    before_action :block_service_partner_from_new_or_destroy, only: %i[new create destroy]

    def find_resource
      scope = scoped_collection
      scope = scope.where(id: current_admin_user.service_center_id) if current_admin_user.service_partner?
      scope.find(params[:id])
    end

    def build_resource
      super.tap { |r| r.service_type = params[:type] if params[:type].present? && r.service_type.blank? }
    end

    private

    # A service_partner has exactly one center — skip the list and go
    # straight to editing it, matching how they'd actually use this page.
    def redirect_service_partner_to_own_center
      return unless current_admin_user.service_partner?
      redirect_to edit_admin_service_center_path(current_admin_user.service_center)
    end

    def block_service_partner_from_new_or_destroy
      return unless current_admin_user.service_partner?
      redirect_to edit_admin_service_center_path(current_admin_user.service_center),
                  alert: "ທ່ານບໍ່ມີສິດເຮັດລາຍການນີ້"
    end
  end
end
