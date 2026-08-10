ActiveAdmin.register InsuranceCompany do
  menu label: "ບໍລິສັດປະກັນໄພ", priority: 6, if: -> { !current_admin_user.partner? }

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
    def scoped_collection
      scope = super
      scope = scope.where(id: current_admin_user.insurance_company_id) if current_admin_user.insurance?
      scope
    end

    def find_resource
      scoped_collection.includes(:insurance_packages).find(params[:id])
    end
  end
end
