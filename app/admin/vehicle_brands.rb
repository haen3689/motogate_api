ActiveAdmin.register VehicleBrand do
  menu false

  permit_params :name, :status

  config.filters = false
  config.batch_actions = false

  index as: :content do
    render partial: "active_admin/vehicle_brands_content"
  end

  show do
    render partial: "active_admin/vehicle_brand_show_content"
  end

  form partial: "active_admin/vehicle_brand_form_content"
end
