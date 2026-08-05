# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: "Dashboard"

  content title: "Master Dashboard" do
    render partial: "active_admin/dashboard_content"
  end
end
