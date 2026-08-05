class Api::V1::VehicleBrandsController < ApiController
  skip_before_action :authenticate!, only: %i[index]

  def index
    render_success(VehicleBrand.active.order(:name).as_json)
  end
end
