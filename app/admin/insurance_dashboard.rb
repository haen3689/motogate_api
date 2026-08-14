ActiveAdmin.register_page "Insurance Dashboard" do
  menu false

  content title: "Dashboard ປະກັນໄພ" do
    render partial: "active_admin/insurance_dashboard_admin_content"
  end
end
