ActiveAdmin.register AdminUser do
  menu label: "ຜູ້ດູແລລະບົບ", if: -> { !current_admin_user.partner? && !current_admin_user.insurance? && !current_admin_user.service_partner? }

  permit_params :email, :password, :password_confirmation, :role, :inspection_center_id, :insurance_company_id, :service_center_id, :custom_role_id, :is_support_agent

  config.filters = false
  config.batch_actions = false

  index as: :content do
    render partial: "active_admin/admin_users_content"
  end

  show do
    render partial: "active_admin/admin_user_show_content"
  end

  form partial: "active_admin/admin_user_form_content"
end
