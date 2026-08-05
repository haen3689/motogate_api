ActiveAdmin.register Insurance do
  menu label: "ປະກັນໄພ", priority: 5

  permit_params :vehicle_id, :company, :package, :amount, :status, :start_date, :end_date

  index do
    selectable_column
    id_column
    column("ລົດ")        { |ins| link_to ins.vehicle.plate_number, admin_vehicle_path(ins.vehicle) }
    column("ບໍລິສັດ")   { |ins| ins.company }
    column("ແພັກເກດ")   { |ins| ins.package }
    column("ຈຳນວນ")     { |ins| number_to_currency(ins.amount, unit: "₭", precision: 0, delimiter: ",") }
    column("ສະຖານະ")    { |ins| status_tag ins.status }
    column("ໝົດອາຍຸ")   { |ins| ins.end_date }
    column :created_at
    actions
  end

  filter :company
  filter :status, as: :select, collection: Insurance::STATUSES
  filter :start_date
  filter :end_date
  filter :created_at

  show do
    attributes_table title: "ລາຍລະອຽດ" do
      row :id
      row("ລົດ")       { |ins| link_to ins.vehicle.plate_number, admin_vehicle_path(ins.vehicle) }
      row("ເຈົ້າຂອງ")  { |ins| link_to ins.vehicle.user.phone_number, admin_user_path(ins.vehicle.user) }
      row("ບໍລິສັດ")   { |ins| ins.company }
      row("ແພັກເກດ")   { |ins| ins.package }
      row("ຈຳນວນ")     { |ins| number_to_currency(ins.amount, unit: "₭", precision: 0, delimiter: ",") }
      row("ສະຖານະ")    { |ins| status_tag ins.status }
      row("ເລີ່ມ")      { |ins| ins.start_date }
      row("ໝົດອາຍຸ")   { |ins| ins.end_date }
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "ຂໍ້ມູນປະກັນໄພ" do
      f.input :vehicle, as: :select,
              collection: Vehicle.joins(:user).map { |v| ["#{v.plate_number} (#{v.user.phone_number})", v.id] }
      f.input :company,    label: "ບໍລິສັດ"
      f.input :package,    label: "ແພັກເກດ"
      f.input :amount,     label: "ຈຳນວນ (₭)"
      f.input :status,     as: :select, collection: Insurance::STATUSES, label: "ສະຖານະ"
      f.input :start_date, as: :date_picker, label: "ວັນເລີ່ມ"
      f.input :end_date,   as: :date_picker, label: "ວັນໝົດອາຍຸ"
    end
    f.actions
  end
end
