# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: "Dashboard"

  content title: "Master Dashboard" do
    if current_admin_user.partner?
      render partial: "active_admin/partner_dashboard_content"
    else
      render partial: "active_admin/dashboard_content"
    end
  end
end
