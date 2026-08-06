ActiveAdmin.register InsuranceCompany do
  menu label: "ບໍລິສັດປະກັນໄພ", priority: 6

  config.batch_actions = false
  config.filters = false

  permit_params :name, :logo, :logo_file, :phone, :email, :status, :description,
    insurance_packages_attributes: [:id, :name, :vehicle_type, :min_cc, :max_cc, :min_seats, :max_seats,
      :min_weight, :max_weight, :usage_type, :price, :coverage, :duration_months, :status, :_destroy]

  index as: :content do
    render partial: "active_admin/insurance_companies_content"
  end

  show do
    attributes_table title: "ລາຍລະອຽດບໍລິສັດ" do
      row :id
      row :name
      row :phone
      row :email
      row("ສະຖານະ") { |c| status_tag c.status }
      row("ລາຍລະອຽດ") { |c| simple_format(c.description) if c.description.present? }
      row :created_at
      row :updated_at
    end

    panel "ແພັກເກັດປະກັນໄພ" do
      table_for insurance_company.insurance_packages do
        column :name
        column("ປະເພດ") { |p| p.vehicle_type }
        column("ຂອບເຂດ") { |p|
          if InsurancePackage::SEAT_BASED_TYPES.include?(p.vehicle_type)
            "#{p.min_seats} - #{p.max_seats} ບ່ອນນັ່ງ"
          elsif InsurancePackage::WEIGHT_BASED_TYPES.include?(p.vehicle_type)
            "#{p.min_weight} - #{p.max_weight} ຕັນ"
          else
            "#{p.min_cc} - #{p.max_cc} CC"
          end
        }
        column("ການນຳໃຊ້") { |p| p.usage_type.presence || "ທຸກປະເພດ" }
        column("ລາຄາ") { |p| number_to_currency(p.price, unit: "₭", precision: 0, delimiter: ",") }
        column("ໄລຍະ") { |p| "#{p.duration_months} ເດືອນ" }
        column("ສະຖານະ") { |p| status_tag p.status }
      end
    end
  end

  form partial: "active_admin/insurance_company_form_content"

  controller do
    def find_resource
      scoped_collection.includes(:insurance_packages).find(params[:id])
    end
  end
end
