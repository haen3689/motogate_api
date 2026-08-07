ActiveAdmin.register RoadTaxRate do
  menu label: "ອັດຕາຄ່າທາງ", priority: 4, if: -> { !current_admin_user.partner? }

  permit_params :vehicle_type, :min_cc, :max_cc, :min_seats, :max_seats, :min_weight, :max_weight, :price, :status

  index do
    selectable_column
    id_column
    column("ປະເພດລົດ") { |r| r.vehicle_type }
    column("ຂອບເຂດ") { |r|
      if RoadTaxRate::SEAT_BASED_TYPES.include?(r.vehicle_type)
        "#{r.min_seats} - #{r.max_seats} ບ່ອນນັ່ງ"
      elsif RoadTaxRate::WEIGHT_BASED_TYPES.include?(r.vehicle_type)
        "#{r.min_weight} - #{r.max_weight} ຕັນ"
      else
        "#{r.min_cc} - #{r.max_cc} CC"
      end
    }
    column("ລາຄາ") { |r| number_to_currency(r.price, unit: "₭", precision: 0, delimiter: ",") }
    column("ສະຖານະ") { |r| status_tag r.status }
    actions
  end

  filter :vehicle_type, as: :select, collection: RoadTaxRate::VEHICLE_TYPES
  filter :status, as: :select, collection: RoadTaxRate::STATUSES

  show do
    attributes_table title: "ອັດຕາຄ່າທາງ" do
      row :id
      row("ປະເພດລົດ") { |r| r.vehicle_type }
      row("CC") { |r| "#{r.min_cc} - #{r.max_cc}" }
      row("ບ່ອນນັ່ງ") { |r| "#{r.min_seats} - #{r.max_seats}" }
      row("ນ້ຳໜັກ (ຕັນ)") { |r| "#{r.min_weight} - #{r.max_weight}" }
      row("ລາຄາ") { |r| number_to_currency(r.price, unit: "₭", precision: 0, delimiter: ",") }
      row("ສະຖານະ") { |r| status_tag r.status }
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "ອັດຕາຄ່າທາງ" do
      f.input :vehicle_type, as: :select,
        collection: [['ລົດຈັກ', 'motorcycle'], ['ລົດເກັ່ງ', 'car'], ['ລົດກະບະ', 'pickup'], ['ລົດຈິບ', 'suv'],
                     ['ລົດຕູ້', 'van'], ['ລົດເມ', 'bus'], ['ລົດລາກ', 'towtruck'], ['ລົດພ່ວງ', 'trailer']],
        include_blank: false, label: "ປະເພດລົດ"
      f.input :min_cc, label: "CC ຕ່ຳ", hint: "ໃຊ້ກັບ: ລົດຈັກ, ລົດເກັ່ງ, ລົດກະບະ, ລົດຈິບ"
      f.input :max_cc, label: "CC ສູງ"
      f.input :min_seats, label: "ບ່ອນນັ່ງ ຕ່ຳ", hint: "ໃຊ້ກັບ: ລົດຕູ້, ລົດເມ"
      f.input :max_seats, label: "ບ່ອນນັ່ງ ສູງ"
      f.input :min_weight, label: "ນ້ຳໜັກ ຕ່ຳ (ຕັນ)", hint: "ໃຊ້ກັບ: ລົດລາກ, ລົດພ່ວງ"
      f.input :max_weight, label: "ນ້ຳໜັກ ສູງ (ຕັນ)"
      f.input :price, label: "ລາຄາ (₭)"
      f.input :status, as: :select, collection: RoadTaxRate::STATUSES, include_blank: false, label: "ສະຖານະ"
    end
    f.actions
  end
end
