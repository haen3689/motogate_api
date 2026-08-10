ActiveAdmin.register RoadTaxSetting do
  menu label: "ຄ່າທຳນຽມແພລດຟອມ", priority: 5, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  actions :show, :edit, :update
  config.batch_actions = false

  permit_params :fee_type, :flat_amount, :percent_rate

  controller do
    def find_resource
      RoadTaxSetting.current
    end

    def show
      redirect_to edit_admin_road_tax_setting_path(resource)
    end
  end

  form partial: "active_admin/road_tax_setting_form_content"
end
