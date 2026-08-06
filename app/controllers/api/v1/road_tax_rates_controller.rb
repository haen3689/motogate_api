class Api::V1::RoadTaxRatesController < ApiController
  skip_before_action :authenticate!, only: %i[index]

  def index
    render_success(RoadTaxRate.active.as_json(
      only: %i[id vehicle_type min_cc max_cc min_seats max_seats min_weight max_weight price status]
    ))
  end
end
