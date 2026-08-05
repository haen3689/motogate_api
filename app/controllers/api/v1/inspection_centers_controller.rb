class Api::V1::InspectionCentersController < ApiController
  skip_before_action :authenticate!, only: %i[index show]

  def index
    centers = InspectionCenter.active.order(:name)
    render_success(centers.as_json(include: { inspection_services: { only: %i[id name vehicle_type min_cc max_cc price detail status] } }))
  end

  def show
    center = InspectionCenter.find(params[:id])
    render_success(center.as_json(include: { inspection_services: { only: %i[id name vehicle_type min_cc max_cc price detail status] } }))
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບສູນກວດກາ", status: :not_found)
  end
end
