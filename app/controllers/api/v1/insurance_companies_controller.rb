class Api::V1::InsuranceCompaniesController < ApiController
  skip_before_action :authenticate!, only: %i[index show]

  def index
    companies = InsuranceCompany.active.order(:name)
    render_success(companies.as_json(include: { insurance_packages: { only: %i[id name vehicle_type min_cc max_cc price coverage duration_months status] } }))
  end

  def show
    company = InsuranceCompany.find(params[:id])
    render_success(company.as_json(include: { insurance_packages: { only: %i[id name vehicle_type min_cc max_cc price coverage duration_months status] } }))
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບບໍລິສັດປະກັນໄພ", status: :not_found)
  end
end
