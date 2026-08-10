ActiveAdmin.register Insurance do
  menu label: "ປະກັນໄພ", priority: 5, if: -> { !current_admin_user.partner? }

  permit_params :vehicle_id, :company, :package, :amount, :status, :start_date, :end_date

  config.filters = false
  config.batch_actions = false

  controller do
    def scoped_collection
      scope = super
      scope = scope.where(insurance_company_id: current_admin_user.insurance_company_id) if current_admin_user.insurance?
      scope
    end

    def find_resource
      scope = scoped_collection
      scope.find(params[:id])
    end
  end

  index as: :content do
    render partial: "active_admin/insurances_content"
  end

  show do
    render partial: "active_admin/insurance_show_content"
  end

  form partial: "active_admin/insurance_form_content"
end
