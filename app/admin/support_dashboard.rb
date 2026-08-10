ActiveAdmin.register_page "Support Dashboard" do
  menu label: "Dashboard Support", priority: 10, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  content title: "Dashboard ຫ້ອງສົນທະນາ" do
    render partial: "active_admin/support_dashboard_content"
  end
end
