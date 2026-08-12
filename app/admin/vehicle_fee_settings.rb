ActiveAdmin.register VehicleFeeSetting do
  menu label: "ຄ່າທຳນຽມລົງທະບຽນລົດ", priority: 6, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  actions :show, :edit, :update
  config.batch_actions = false

  permit_params :amount

  controller do
    def find_resource
      VehicleFeeSetting.current
    end

    def show
      redirect_to edit_admin_vehicle_fee_setting_path(resource)
    end
  end

  form partial: "active_admin/vehicle_fee_setting_form_content"
end
