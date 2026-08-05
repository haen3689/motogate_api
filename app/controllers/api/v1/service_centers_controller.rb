class Api::V1::ServiceCentersController < ApiController
  skip_before_action :authenticate!, only: %i[index show]

  def index
    centers = ServiceCenter.active
    centers = centers.where(service_type: params[:type]) if params[:type].present?
    render_success(centers.order(rating: :desc).as_json)
  end

  def show
    center = ServiceCenter.find(params[:id])
    render_success(center.as_json)
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບສູນບໍລິການ", status: :not_found)
  end
end
