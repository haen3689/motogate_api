ActiveAdmin.register_page "Reports" do
  menu label: "ລາຍງານ", priority: 8, icon: "fa fa-chart-bar"

  content title: "ລາຍງານທັງໝົດ" do
    if current_admin_user.partner?
      render partial: "active_admin/partner_reports_content"
    else
      render partial: "active_admin/reports_content"
    end
  end
end
