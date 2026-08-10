ActiveAdmin.register_page "Support Feedback" do
  menu label: "Feedback", priority: 15, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  content title: "ຄວາມຄິດເຫັນຈາກລູກຄ້າ" do
    render partial: "active_admin/support_feedback_content"
  end
end
