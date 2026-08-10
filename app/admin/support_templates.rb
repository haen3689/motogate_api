ActiveAdmin.register SupportTemplate do
  menu label: "ຄຳຕອບດ່ວນ", priority: 13, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  permit_params :title, :body, :position

  config.filters = false
  config.batch_actions = false

  index as: :content do
    render partial: "active_admin/support_templates_content"
  end

  show do
    render partial: "active_admin/support_template_show_content"
  end

  form partial: "active_admin/support_template_form_content"
end
