class Api::V1::ServiceCentersController < ApiController
  skip_before_action :authenticate!, only: %i[index show]

  def index
    centers = ServiceCenter.active.includes(:service_center_contracts)
    centers = centers.where(service_type: params[:type]) if params[:type].present?
    visible = centers.order(rating: :desc).select(&:visible_in_app?)
    render_success(visible.map(&:as_json))
  end

  def show
    center = ServiceCenter.find(params[:id])
    return render_error("ບໍ່ພົບສູນບໍລິການ", status: :not_found) unless center.visible_in_app?
    render_success(center.as_json)
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບສູນບໍລິການ", status: :not_found)
  end
end
