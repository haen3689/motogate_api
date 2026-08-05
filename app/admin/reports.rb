ActiveAdmin.register_page "Reports" do
  menu label: "ລາຍງານ", priority: 8, icon: "fa fa-chart-bar"

  content title: "ລາຍງານທັງໝົດ" do
    render partial: "active_admin/reports_content"
  end
end
