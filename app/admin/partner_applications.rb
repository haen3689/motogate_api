ActiveAdmin.register PartnerApplication do
  menu false

  permit_params :business_name, :service_type, :owner_name, :phone, :location, :notes

  config.filters = false
  config.batch_actions = false

  member_action :approve, method: :post do
    application = resource
    if application.approve!(current_admin_user)
      redirect_to admin_partner_applications_path(type: application.service_type), notice: "ອະນຸມັດແລ້ວ — ສ້າງສູນບໍລິການໃໝ່ຮຽບຮ້ອຍ"
    else
      redirect_to admin_partner_applications_path(type: application.service_type), alert: "ບໍ່ສາມາດອະນຸມັດໄດ້"
    end
  end

  member_action :reject, method: :post do
    application = resource
    application.reject!(current_admin_user, reason: params[:reason])
    redirect_to admin_partner_applications_path(type: application.service_type), notice: "ປະຕິເສດຄຳສະໝັກແລ້ວ"
  end

  index as: :content do
    render partial: "active_admin/partner_applications_content"
  end

  show do
    render partial: "active_admin/partner_application_show_content"
  end
end
