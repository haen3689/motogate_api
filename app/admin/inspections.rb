ActiveAdmin.register Inspection do
  menu label: "ກວດສະພາບລົດ", priority: 5

  config.batch_actions = false
  config.filters = false

  permit_params :status, :notes, :sticker_file, :sticker_number

  index as: :content do
    render partial: "active_admin/inspections_content"
  end

  show as: :content do
    render partial: "active_admin/inspection_show_content"
  end

  form partial: "active_admin/inspection_form_content"

  controller do
    def find_resource
      scope = scoped_collection.includes(vehicle: :user)
      scope = scope.where(inspection_center_id: current_admin_user.inspection_center_id) if current_admin_user.partner?
      scope.find(params[:id])
    end
  end
end
