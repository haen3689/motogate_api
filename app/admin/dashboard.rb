# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: "Dashboard"

  controller do
    before_action :redirect_service_partner_to_overview

    def redirect_service_partner_to_overview
      return unless current_admin_user.service_partner?
      redirect_to admin_service_center_overview_path(type: current_admin_user.service_center.service_type)
    end
  end

  content title: "Master Dashboard" do
    if current_admin_user.partner?
      render partial: "active_admin/partner_dashboard_content"
    elsif current_admin_user.insurance?
      render partial: "active_admin/insurance_dashboard_content"
    elsif current_admin_user.staff?
      render partial: "active_admin/staff_dashboard_content"
    else
      render partial: "active_admin/dashboard_content"
    end
  end
end
