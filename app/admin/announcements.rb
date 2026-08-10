ActiveAdmin.register Announcement do
  menu label: "ປະກາດ", priority: 13, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  permit_params :title, :body, :image_file, :position, :active, :category, :author

  config.filters = false
  config.batch_actions = false

  index as: :content do
    render partial: "active_admin/announcements_content"
  end

  show do
    render partial: "active_admin/announcement_show_content"
  end

  form partial: "active_admin/announcement_form_content"
end
