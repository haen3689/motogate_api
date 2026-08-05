ActiveAdmin.register Inspection do
  menu priority: 5

  permit_params :status, :notes

  index do
    selectable_column
    id_column
    column :vehicle do |i| i.vehicle.plate_number end
    column :center_name
    column :appointment_at
    column :status do |i| status_tag i.status, class: i.status end
    column :created_at
    actions
  end

  filter :status, as: :select, collection: Inspection::STATUSES
  filter :center_name
  filter :appointment_at

  show do
    attributes_table do
      row :id
      row :vehicle do |i| link_to i.vehicle.plate_number, admin_vehicle_path(i.vehicle) end
      row :center_name
      row :center_address
      row :appointment_at
      row :status do |i| status_tag i.status end
      row :notes
      row :created_at
    end
  end

  form do |f|
    f.inputs do
      f.input :status, as: :select, collection: Inspection::STATUSES
      f.input :notes
    end
    f.actions
  end
end
