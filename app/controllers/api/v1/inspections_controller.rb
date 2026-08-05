class Api::V1::InspectionsController < ApiController
  def index
    inspections = Inspection.joins(:vehicle).where(vehicles: { user_id: current_user.id })
    render_success(inspections.order(created_at: :desc).as_json)
  end

  def show
    inspection = user_inspections.find(params[:id])
    render_success(inspection.as_json)
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບຂໍ້ມູນ", status: :not_found)
  end

  def create
    vehicle = current_user.vehicles.find(params[:vehicle_id])
    inspection = vehicle.inspections.build(inspection_params)
    if inspection.save
      render_success(inspection.as_json, status: :created)
    else
      render_error(inspection.errors.full_messages.join(", "))
    end
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບລົດ", status: :not_found)
  end

  def update
    inspection = user_inspections.find(params[:id])
    if inspection.update(inspection_params)
      render_success(inspection.as_json)
    else
      render_error(inspection.errors.full_messages.join(", "))
    end
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບຂໍ້ມູນ", status: :not_found)
  end

  private

  def user_inspections
    Inspection.joins(:vehicle).where(vehicles: { user_id: current_user.id })
  end

  def inspection_params
    params.permit(:center_name, :center_address, :appointment_at, :status, :notes)
  end
end
