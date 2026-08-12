ActiveAdmin.register VehicleFeeRate do
  menu false # linked from the custom sidebar instead (app/views/active_admin/_sidebar.html.erb)

  actions :index
  config.filters = false
  config.batch_actions = false

  # Single-page "settings grid" — one amount field per vehicle type, saved
  # together, rather than separate CRUD pages per row (there's always
  # exactly one rate per type, never more/fewer).
  collection_action :bulk_update, method: :post do
    VehicleFeeRate.ensure_defaults!
    Vehicle::VEHICLE_TYPES.each do |type|
      amount = params.dig(:amounts, type)
      next if amount.blank?

      VehicleFeeRate.find_by(vehicle_type: type)&.update(amount: amount)
    end
    redirect_to admin_vehicle_fee_rates_path, notice: "ບັນທຶກສຳເລັດ"
  end

  index as: :content do
    VehicleFeeRate.ensure_defaults!
    render partial: "active_admin/vehicle_fee_rates_content"
  end
end
