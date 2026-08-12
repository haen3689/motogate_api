class Api::V1::VehicleFeeSettingsController < ApiController
  skip_before_action :authenticate!, only: %i[show]

  def show
    render_success(VehicleFeeSetting.current.as_json(only: %i[amount]))
  end
end
