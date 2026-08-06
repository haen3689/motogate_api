class Api::V1::RoadTaxSettingsController < ApiController
  skip_before_action :authenticate!, only: %i[show]

  def show
    setting = RoadTaxSetting.current
    render_success(setting.as_json(only: %i[fee_type flat_amount percent_rate]))
  end
end
