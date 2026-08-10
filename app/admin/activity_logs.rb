ActiveAdmin.register ActivityLog do
  menu label: "ປະຫວັດ", priority: 14, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  actions :index, :show

  config.filters = false
  config.batch_actions = false

  index as: :content do
    render partial: "active_admin/activity_logs_content"
  end

  show do
    render partial: "active_admin/activity_log_show_content"
  end

  controller do
    def scoped_collection
      super.includes(:admin_user).order(created_at: :desc)
    end
  end
end
