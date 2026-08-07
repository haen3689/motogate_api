ActiveAdmin.register InspectionCenter do
  menu label: "ສູນກວດກາເຕັກນິກ", priority: 6

  config.batch_actions = false
  config.filters = false

  permit_params :name, :location, :phone, :status, :capacity_per_day, :logo_file, :latitude, :longitude,
    inspection_services_attributes: [:id, :name, :vehicle_type, :min_cc, :max_cc, :price, :detail, :status, :_destroy]

  index as: :content do
    render partial: "active_admin/inspection_centers_content"
  end

  show as: :content do
    render partial: "active_admin/inspection_center_show_content"
  end

  form partial: "active_admin/inspection_center_form_content"

  controller do
    before_action :redirect_partner_to_own_center, only: :index
    before_action :block_partner_from_new_or_destroy, only: %i[new create destroy]

    def find_resource
      scope = scoped_collection.includes(:inspection_services)
      scope = scope.where(id: current_admin_user.inspection_center_id) if current_admin_user.partner?
      scope.find(params[:id])
    end

    private

    # A partner has exactly one center — skip the list and go straight
    # to editing it, matching how they'd actually use this page.
    def redirect_partner_to_own_center
      return unless current_admin_user.partner?
      redirect_to edit_admin_inspection_center_path(current_admin_user.inspection_center)
    end

    def block_partner_from_new_or_destroy
      return unless current_admin_user.partner?
      redirect_to edit_admin_inspection_center_path(current_admin_user.inspection_center),
                  alert: "ທ່ານບໍ່ມີສິດເຮັດລາຍການນີ້"
    end
  end
end
