class Dashboard::ServiceCentersController < Dashboard::BaseController
  def index
    @centers = ServiceCenter.order(rating: :desc)
    @centers = @centers.where(service_type: params[:type]) if params[:type].present?
  end

  def show
    @center = ServiceCenter.find(params[:id])
  end
end
