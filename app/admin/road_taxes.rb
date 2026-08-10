ActiveAdmin.register RoadTax do
  menu label: "ເສຍຄ່າທາງ", priority: 4, if: -> { !current_admin_user.partner? && !current_admin_user.insurance? }

  permit_params :vehicle_id, :tax_year, :amount, :service_fee, :status, :source, :paid_at, :expired_at, :proof_image

  config.filters = false
  config.batch_actions = false

  index as: :content do
    render partial: "active_admin/road_taxes_content"
  end

  show do
    render partial: "active_admin/road_tax_show_content"
  end

  form partial: "active_admin/road_tax_form_content"
end
