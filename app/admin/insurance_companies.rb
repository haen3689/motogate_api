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
    render partial: "active_admin/insurance_company_show_content", locals: { company: insurance_company }
  end

  form partial: "active_admin/insurance_company_form_content"

  controller do
    def find_resource
      scoped_collection.includes(:insurance_packages).find(params[:id])
    end
  end
end
