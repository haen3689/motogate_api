ActiveAdmin.register Advertisement do
  menu label: "ຈັດການໂຄສະນາ", priority: 11, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  permit_params :title, :subtitle, :image_file, :link_url, :position, :active, :placement, :start_date, :end_date

  config.filters = false
  config.batch_actions = false

  index as: :content do
    render partial: "active_admin/advertisements_content"
  end

  show do
    render partial: "active_admin/advertisement_show_content"
  end

  form partial: "active_admin/advertisement_form_content"
end
