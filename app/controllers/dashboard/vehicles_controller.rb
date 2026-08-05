class Dashboard::VehiclesController < Dashboard::BaseController
  def index
    @vehicles = Vehicle.includes(:user).order(created_at: :desc)
    @vehicles = @vehicles.where("plate_number ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    @vehicles = @vehicles.where(vehicle_type: params[:type]) if params[:type].present?
    @vehicles = @vehicles.where(year: params[:year]) if params[:year].present?
    @total    = Vehicle.count
    @moto     = Vehicle.where(vehicle_type: 'motorcycle').count
    @car      = Vehicle.where(vehicle_type: 'car').count
    @truck    = Vehicle.where(vehicle_type: 'truck').count
  end

  def show
    @vehicle = Vehicle.includes(:user, :road_taxes, :inspections).find(params[:id])
  end

  def destroy
    @vehicle = Vehicle.find(params[:id])
    @vehicle.destroy
    redirect_to dashboard_vehicles_path, notice: 'ລົບຂໍ້ມູນລົດສຳເລັດ'
  end
end
