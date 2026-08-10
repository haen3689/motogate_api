ActiveAdmin.register Role do
  menu label: "ຈັດການສິດທິ໌", priority: 20, if: -> { current_admin_user.superadmin? }

  permit_params :key, :name,
    permissions_attributes: [:id, :resource, :can_read, :can_create, :can_update, :can_delete]

  config.filters = false
  config.batch_actions = false

  controller do
    before_action :require_superadmin!

    def require_superadmin!
      return if current_admin_user.superadmin?
      redirect_to admin_dashboard_path, alert: "ສະເພາະ Superadmin ເທົ່ານັ້ນ"
    end

    def build_resource
      resource = super
      if resource.permissions.empty?
        Permission::CATALOG.keys.each { |k| resource.permissions.build(resource: k, can_read: false) }
      end
      resource
    end

    def edit
      resource.ensure_full_permission_set!
      super
    end
  end

  index as: :content do
    render partial: "active_admin/roles_content"
  end

  show do
    render partial: "active_admin/role_show_content"
  end

  form partial: "active_admin/role_form_content"
end
