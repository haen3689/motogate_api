ActiveAdmin.register ServiceCenterContract do
  menu false

  permit_params :service_center_id, :rent_amount, :billing_cycle, :start_date, :end_date, :status, :notes

  config.filters = false
  config.batch_actions = false

  member_action :add_payment, method: :post do
    contract = resource
    if current_admin_user.service_partner?
      redirect_to admin_service_center_contract_path(contract), alert: "ທ່ານບໍ່ມີສິດເຮັດລາຍການນີ້" and return
    end
    if params[:amount].present? && params[:paid_at].present?
      contract.service_center_payments.create!(
        amount: params[:amount],
        paid_at: params[:paid_at],
        period_label: params[:period_label],
        payment_method: params[:payment_method].presence_in(ServiceCenterPayment::METHODS),
        status: params[:status].presence_in(ServiceCenterPayment::STATUSES) || "paid"
      )
    end
    redirect_to admin_service_center_contract_path(contract)
  end

  member_action :mark_payment_paid, method: :post do
    contract = resource
    if current_admin_user.service_partner?
      redirect_to admin_service_center_contract_path(contract), alert: "ທ່ານບໍ່ມີສິດເຮັດລາຍການນີ້" and return
    end
    payment = contract.service_center_payments.find(params[:payment_id])
    payment.update!(status: "paid")
    redirect_to admin_service_center_contract_path(contract)
  end

  member_action :cancel, method: :post do
    contract = resource
    if current_admin_user.service_partner?
      redirect_to admin_service_center_contracts_path(type: current_admin_user.service_center.service_type),
                  alert: "ທ່ານບໍ່ມີສິດເຮັດລາຍການນີ້" and return
    end
    contract.update!(status: "terminated")
    redirect_to admin_service_center_contracts_path(type: contract.service_center.service_type),
                notice: "ຍົກເລີກສັນຍາ #{contract.contract_number} ແລ້ວ"
  end

  index as: :content do
    render partial: "active_admin/service_center_contracts_content"
  end

  show do
    render partial: "active_admin/service_center_contract_show_content"
  end

  form partial: "active_admin/service_center_contract_form_content"

  controller do
    before_action :block_service_partner_from_write, only: %i[new create edit update destroy]

    def find_resource
      scope = scoped_collection
      scope = scope.where(service_center_id: current_admin_user.service_center_id) if current_admin_user.service_partner?
      scope.find(params[:id])
    end

    private

    # Contracts are between MotoGate and the partner — the partner can view
    # their own contract & payment history but only staff can create/edit
    # terms or record a payment (see the add_payment/mark_payment_paid
    # member_actions above).
    def block_service_partner_from_write
      return unless current_admin_user.service_partner?
      redirect_to admin_service_center_contracts_path(type: current_admin_user.service_center.service_type),
                  alert: "ທ່ານບໍ່ມີສິດເຮັດລາຍການນີ້"
    end
  end
end
