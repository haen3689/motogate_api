class Api::V1::InsurancesController < ApiController
  def index
    insurances = Insurance.joins(:vehicle).where(vehicles: { user_id: current_user.id })
    render_success(insurances.order(created_at: :desc).as_json)
  end

  def show
    insurance = user_insurances.find(params[:id])
    render_success(insurance.as_json)
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບຂໍ້ມູນ", status: :not_found)
  end

  def create
    vehicle = current_user.vehicles.find(params[:vehicle_id])
    insurance = vehicle.insurances.build(insurance_params)
    if insurance.save
      render_success(insurance.as_json, status: :created)
    else
      render_error(insurance.errors.full_messages.join(", "))
    end
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບລົດ", status: :not_found)
  end

  private

  def user_insurances
    Insurance.joins(:vehicle).where(vehicles: { user_id: current_user.id })
  end

  def insurance_params
    params.permit(:company, :package, :amount, :status, :start_date, :end_date)
  end
end
