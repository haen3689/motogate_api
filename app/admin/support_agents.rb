ActiveAdmin.register_page "Support Agents" do
  menu label: "Support Agents", priority: 14, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  content title: "ຕິດຕາມການເຮັດວຽກ Support Agent" do
    render partial: "active_admin/support_agents_content"
  end
end
