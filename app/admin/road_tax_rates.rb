ActiveAdmin.register RoadTaxRate do
  menu label: "ອັດຕາຄ່າທາງ", priority: 4, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  permit_params :vehicle_type, :min_cc, :max_cc, :min_seats, :max_seats, :min_weight, :max_weight, :price, :status

  config.filters = false
  config.batch_actions = false

  index as: :content do
    render partial: "active_admin/road_tax_rates_content"
  end

  show do
    render partial: "active_admin/road_tax_rate_show_content"
  end

  form partial: "active_admin/road_tax_rate_form_content"
end
