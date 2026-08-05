ActiveAdmin.register RoadTax do
  menu label: "ເສຍຄ່າທາງ", priority: 4

  permit_params :vehicle_id, :tax_year, :amount, :status, :expired_at

  index do
    selectable_column
    id_column
    column("ລົດ")       { |rt| link_to rt.vehicle.plate_number, admin_vehicle_path(rt.vehicle) }
    column("ປີ")        { |rt| rt.tax_year }
    column("ຈຳນວນ")    { |rt| number_to_currency(rt.amount, unit: "₭", precision: 0, delimiter: ",") }
    column("ສະຖານະ")   { |rt| status_tag rt.status }
    column("ໝົດອາຍຸ")  { |rt| rt.expired_at }
    column :created_at
    actions
  end

  filter :tax_year
  filter :status, as: :select, collection: RoadTax::STATUSES
  filter :expired_at
  filter :created_at

  show do
    attributes_table title: "ລາຍລະອຽດ" do
      row :id
      row("ລົດ")      { |rt| link_to rt.vehicle.plate_number, admin_vehicle_path(rt.vehicle) }
      row("ເຈົ້າຂອງ") { |rt| link_to rt.vehicle.user.phone_number, admin_user_path(rt.vehicle.user) }
      row("ປີ")       { |rt| rt.tax_year }
      row("ຈຳນວນ")   { |rt| number_to_currency(rt.amount, unit: "₭", precision: 0, delimiter: ",") }
      row("ສະຖານະ")  { |rt| status_tag rt.status }
      row("ໝົດອາຍຸ") { |rt| rt.expired_at }
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "ຂໍ້ມູນຄ່າທາງ" do
      f.input :vehicle, as: :select,
              collection: Vehicle.joins(:user).map { |v| ["#{v.plate_number} (#{v.user.phone_number})", v.id] }
      f.input :tax_year, label: "ປີ"
      f.input :amount,   label: "ຈຳນວນ (₭)"
      f.input :status,   as: :select, collection: RoadTax::STATUSES, label: "ສະຖານະ"
      f.input :expired_at, as: :date_picker, label: "ວັນໝົດອາຍຸ"
    end
    f.actions
  end
end
