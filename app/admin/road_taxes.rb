ActiveAdmin.register RoadTax do
  menu label: "ເສຍຄ່າທາງ", priority: 4, if: -> { !current_admin_user.partner? }

  permit_params :vehicle_id, :tax_year, :amount, :service_fee, :status, :source, :paid_at, :expired_at

  index do
    selectable_column
    id_column
    column("ລົດ")       { |rt| link_to rt.vehicle.plate_number, admin_vehicle_path(rt.vehicle) }
    column("ປີ")        { |rt| rt.tax_year }
    column("ຈຳນວນ")    { |rt| number_to_currency(rt.amount, unit: "₭", precision: 0, delimiter: ",") }
    column("ຄ່າທຳນຽມ")  { |rt| rt.service_fee.present? ? number_to_currency(rt.service_fee, unit: "₭", precision: 0, delimiter: ",") : "—" }
    column("ແຫຼ່ງທີ່ມາ") { |rt| rt.source == 'external_upload' ? 'ອັບໂຫລດຫຼັກຖານ' : 'ຈ່າຍໃນແອບ' }
    column("ສະຖານະ")   { |rt| status_tag rt.status }
    column("ໝົດອາຍຸ")  { |rt| rt.expired_at }
    column :created_at
    actions
  end

  filter :tax_year
  filter :status, as: :select, collection: RoadTax::STATUSES
  filter :source, as: :select, collection: RoadTax::SOURCES
  filter :expired_at
  filter :created_at

  show do
    attributes_table title: "ລາຍລະອຽດ" do
      row :id
      row("ລົດ")      { |rt| link_to rt.vehicle.plate_number, admin_vehicle_path(rt.vehicle) }
      row("ເຈົ້າຂອງ") { |rt| link_to rt.vehicle.user.phone_number, admin_user_path(rt.vehicle.user) }
      row("ປີ")       { |rt| rt.tax_year }
      row("ຈຳນວນຄ່າທາງ (ອ້າງອີງ)")   { |rt| number_to_currency(rt.amount, unit: "₭", precision: 0, delimiter: ",") }
      row("ຄ່າທຳນຽມແພລດຟອມ") { |rt| rt.service_fee.present? ? number_to_currency(rt.service_fee, unit: "₭", precision: 0, delimiter: ",") : "—" }
      row("ແຫຼ່ງທີ່ມາ") { |rt| rt.source == 'external_upload' ? 'ອັບໂຫລດຫຼັກຖານ (ຈ່າຍນອກລະບົບ)' : 'ຈ່າຍໃນແອບ' }
      row("ຫຼັກຖານ") { |rt|
        if rt.proof_image.attached?
          link_to image_tag(url_for(rt.proof_image), style: "max-width:220px;border-radius:10px;"), url_for(rt.proof_image), target: "_blank"
        else
          "—"
        end
      }
      row("ສະຖານະ")  { |rt| status_tag rt.status }
      row("ວັນທີ່ຈ່າຍ") { |rt| rt.paid_at }
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
      f.input :amount,   label: "ຈຳນວນຄ່າທາງ (₭)"
      f.input :service_fee, label: "ຄ່າທຳນຽມແພລດຟອມ (₭)"
      f.input :status,   as: :select, collection: RoadTax::STATUSES, label: "ສະຖານະ"
      f.input :source,   as: :select, collection: RoadTax::SOURCES, include_blank: false, label: "ແຫຼ່ງທີ່ມາ"
      f.input :paid_at, as: :date_picker, label: "ວັນທີ່ຈ່າຍ"
      f.input :expired_at, as: :date_picker, label: "ວັນໝົດອາຍຸ"
    end
    f.actions
  end
end
