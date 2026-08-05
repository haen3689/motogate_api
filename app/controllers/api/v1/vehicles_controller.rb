class Api::V1::VehiclesController < ApiController
  before_action :set_vehicle, only: %i[show update destroy]

  def index
    render_success(current_user.vehicles.map { |v| vehicle_json(v) })
  end

  def show
    render_success(vehicle_json(@vehicle))
  end

  def create
    vehicle = current_user.vehicles.build(vehicle_params)
    vehicle.registration_front.attach(params[:registration_front]) if params[:registration_front].present?
    vehicle.registration_back.attach(params[:registration_back])   if params[:registration_back].present?
    if vehicle.save
      render_success(vehicle_json(vehicle), status: :created)
    else
      render_error(vehicle.errors.full_messages.join(", "))
    end
  end

  def update
    if @vehicle.update(vehicle_params)
      @vehicle.registration_front.attach(params[:registration_front]) if params[:registration_front].present?
      @vehicle.registration_back.attach(params[:registration_back])   if params[:registration_back].present?
      render_success(vehicle_json(@vehicle))
    else
      render_error(@vehicle.errors.full_messages.join(", "))
    end
  end

  def destroy
    @vehicle.destroy
    render_success({ message: "Vehicle deleted" })
  end

  private

  def set_vehicle
    @vehicle = current_user.vehicles.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error("Vehicle not found", status: :not_found)
  end

  def vehicle_params
    params.permit(:plate_number, :plate_type, :brand, :model, :year, :color, :vehicle_type,
                  :engine_number, :chassis_number, :cc, :province, :usage_type,
                  :owner_name, :fuel_type, :seat_count, :axle_count, :cylinder_count,
                  :registration_expiry_date, :fee_paid)
  end

  def vehicle_json(v)
    v.as_json.merge(
      registration_front_url: v.registration_front.attached? ? url_for(v.registration_front) : nil,
      registration_back_url:  v.registration_back.attached?  ? url_for(v.registration_back)  : nil,
    )
  end
end
