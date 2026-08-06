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

  # Price is computed server-side from the center's InspectionService that
  # matches the vehicle (type/CC) — the client only picks center + vehicle +
  # appointment time, it can't set the amount itself.
  def create
    vehicle = current_user.vehicles.find(params[:vehicle_id])
    center = InspectionCenter.find(params[:inspection_center_id])
    service = center.inspection_services.for_vehicle(vehicle)
    return render_error("ບໍ່ພົບແພັກເກັດກວດກາສຳລັບລົດຄັນນີ້") unless service

    inspection = vehicle.inspections.build(
      center_name: center.name,
      center_address: center.location,
      service_name: service.name,
      amount: service.price,
      appointment_at: params[:appointment_at],
      status: 'confirmed',
      notes: params[:notes]
    )
    if inspection.save
      render_success(inspection.as_json, status: :created)
    else
      render_error(inspection.errors.full_messages.join(", "))
    end
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບລົດ ຫຼື ສູນກວດກາ", status: :not_found)
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
