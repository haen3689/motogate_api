ActiveAdmin.register InspectionCenter do
  menu label: "ສູນກວດກາເຕັກນິກ", priority: 6

  permit_params :name, :location, :phone, :status, :capacity_per_day, :logo_file,
    inspection_services_attributes: [:id, :name, :vehicle_type, :min_cc, :max_cc, :price, :detail, :status, :_destroy]

  index do
    selectable_column
    id_column
    column("ຊື່") { |c| c.name }
    column("ສະຖານທີ່") { |c| c.location }
    column("ເບີໂທ") { |c| c.phone }
    column("ຈຳນວນບໍລິການ") { |c| c.inspection_services.count }
    column("ສະຖານະ") { |c| status_tag c.status }
    actions
  end

  filter :name
  filter :status, as: :select, collection: InspectionCenter::STATUSES

  show do
    attributes_table do
      row :id
      row("ຊື່") { |c| c.name }
      row("ສະຖານທີ່") { |c| c.location }
      row("ເບີໂທ") { |c| c.phone }
      row("ຈຳນວນຮັບໄດ້ຕໍ່ວັນ") { |c| c.capacity_per_day }
      row("ສະຖານະ") { |c| status_tag c.status }
      row("ໂລໂກ້") { |c| image_tag(c.logo, style: "max-height: 120px;") if c.logo.present? }
      row :created_at
      row :updated_at
    end

    panel "ບໍລິການກວດກາ (Services)" do
      table_for resource.inspection_services do
        column("ຊື່") { |s| s.name }
        column("ປະເພດລົດ") { |s| s.vehicle_type }
        column("CC ຕ່ຳ") { |s| s.min_cc }
        column("CC ສູງ") { |s| s.max_cc }
        column("ລາຄາ") { |s| number_to_currency(s.price, unit: "₭", precision: 0, delimiter: ",") if s.price.present? }
        column("ສະຖານະ") { |s| status_tag s.status }
      end
    end
  end

  form do |f|
    f.inputs "ຂໍ້ມູນສູນກວດກາ" do
      f.input :name, label: "ຊື່"
      f.input :location, label: "ສະຖານທີ່"
      f.input :phone, label: "ເບີໂທ"
      f.input :status, as: :select, collection: InspectionCenter::STATUSES, include_blank: false, label: "ສະຖານະ"
      f.input :capacity_per_day, label: "ຈຳນວນຮັບໄດ້ຕໍ່ວັນ"
      if f.object.logo.present?
        f.template.concat f.template.image_tag(f.object.logo, style: "max-height: 100px; display: block; margin-bottom: 10px;")
      end
      f.input :logo_file, as: :file, label: "ໂລໂກ້"
    end

    f.inputs "ບໍລິການ (Services)" do
      f.has_many :inspection_services, allow_destroy: true, new_record: "ເພີ່ມບໍລິການ" do |sf|
        sf.input :name, label: "ຊື່"
        sf.input :vehicle_type, as: :select, collection: InspectionService::VEHICLE_TYPES, include_blank: "ທຸກປະເພດ", label: "ປະເພດລົດ"
        sf.input :min_cc, label: "CC ຕ່ຳ"
        sf.input :max_cc, label: "CC ສູງ"
        sf.input :price, label: "ລາຄາ"
        sf.input :detail, label: "ລາຍລະອຽດ"
        sf.input :status, as: :select, collection: InspectionService::STATUSES, include_blank: false, label: "ສະຖານະ"
      end
    end

    f.actions
  end
end
