class Api::V1::VehicleFeeRatesController < ApiController
  skip_before_action :authenticate!, only: %i[index]

  def index
    VehicleFeeRate.ensure_defaults!
    render_success(VehicleFeeRate.all.as_json(only: %i[vehicle_type amount]))
  end
end
