ActiveAdmin.register InspectionCenter do
  menu label: "ສູນກວດກາເຕັກນິກ", priority: 6

  config.batch_actions = false
  config.filters = false

  permit_params :name, :location, :phone, :status, :capacity_per_day, :logo_file, :latitude, :longitude,
    inspection_services_attributes: [:id, :name, :vehicle_type, :min_cc, :max_cc, :price, :detail, :status, :_destroy]

  index as: :content do
    render partial: "active_admin/inspection_centers_content"
  end

  show as: :content do
    render partial: "active_admin/inspection_center_show_content"
  end

  form partial: "active_admin/inspection_center_form_content"

  controller do
    def find_resource
      scoped_collection.includes(:inspection_services).find(params[:id])
    end
  end
end
