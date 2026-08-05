class Dashboard::InspectionCentersController < Dashboard::BaseController
  def index
    @centers = InspectionCenter.includes(:inspection_services).order(:name)
  end

  def show
    @center = InspectionCenter.includes(:inspection_services).find(params[:id])
  end
end
