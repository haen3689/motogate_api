ActiveAdmin.register Vehicle do
  menu priority: 3, if: -> { !current_admin_user.partner? }
  config.batch_actions = false
  config.filters = false

  permit_params :user_id, :plate_number, :plate_type, :brand, :model, :year, :color, :vehicle_type,
                :engine_number, :chassis_number, :cc, :province, :usage_type,
                :owner_name, :fuel_type, :seat_count, :axle_count, :cylinder_count, :weight,
                :registration_expiry_date,
                :registration_front, :registration_back, :front_photo, :transport_booklet

  index title: false, download_links: false do
    render partial: "active_admin/vehicles_content"
  end

  show do
    render partial: "active_admin/vehicle_show_content", locals: { vehicle: vehicle }
  end

  form partial: "active_admin/vehicle_form_content"
end
