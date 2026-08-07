ActiveAdmin.register InspectionCenter do
  menu label: "ສູນກວດກາເຕັກນິກ", priority: 6

  config.batch_actions = false
  config.filters = false

  permit_params :name, :location, :phone, :status, :capacity_per_day, :logo_file, :latitude, :longitude,
    inspection_services_attributes: [:id, :name, :vehicle_type, :min_cc, :max_cc, :price, :detail, :status, :_destroy]

  index as: :content do
    render partial: "active_admin/inspection_centers_content"
  end

  show do
    attributes_table do
      row :id
      row("ຊື່") { |c| c.name }
      row("ສະຖານທີ່") { |c| c.location }
      row("ເບີໂທ") { |c| c.phone }
      row("ຈຳນວນຮັບໄດ້ຕໍ່ວັນ") { |c| c.capacity_per_day }
      row("ພິກັດ GPS") do |c|
        if c.latitude.present? && c.longitude.present?
          link_to "#{c.latitude}, #{c.longitude} (ເປີດໃນ Google Maps)",
            "https://www.google.com/maps/search/?api=1&query=#{c.latitude},#{c.longitude}",
            target: "_blank", rel: "noopener"
        else
          "ບໍ່ມີຂໍ້ມູນ"
        end
      end
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

  form partial: "active_admin/inspection_center_form_content"

  controller do
    def find_resource
      scoped_collection.includes(:inspection_services).find(params[:id])
    end
  end
end
