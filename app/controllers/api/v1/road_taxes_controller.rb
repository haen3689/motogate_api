class Api::V1::RoadTaxesController < ApiController
  def index
    taxes = RoadTax.joins(:vehicle).where(vehicles: { user_id: current_user.id })
    render_success(taxes.order(created_at: :desc).as_json)
  end

  def show
    tax = user_road_taxes.find(params[:id])
    render_success(tax.as_json)
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບຂໍ້ມູນ", status: :not_found)
  end

  def create
    vehicle = current_user.vehicles.find(params[:vehicle_id])
    tax = vehicle.road_taxes.build(road_tax_params)
    if tax.save
      render_success(tax.as_json, status: :created)
    else
      render_error(tax.errors.full_messages.join(", "))
    end
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບລົດ", status: :not_found)
  end

  private

  def user_road_taxes
    RoadTax.joins(:vehicle).where(vehicles: { user_id: current_user.id })
  end

  def road_tax_params
    params.permit(:tax_year, :amount, :status, :expired_at)
  end
end
