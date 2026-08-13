class Api::V1::InsuranceCompaniesController < ApiController
  skip_before_action :authenticate!, only: %i[index show]

  def index
    companies = InsuranceCompany.active.order(:name)
    render_success(companies.map { |c| company_json(c) })
  end

  def show
    company = InsuranceCompany.find(params[:id])
    render_success(company_json(company))
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບບໍລິສັດປະກັນໄພ", status: :not_found)
  end

  private

  # Only ever exposes *active* packages — InsurancesController#create looks
  # packages up via `company.insurance_packages.active`, so an inactive
  # package showing up here would let a user pick one in the app and then
  # have insurance purchase fail with "package not found" at payment time.
  def company_json(company)
    company.as_json.merge(
      insurance_packages: company.insurance_packages.active.as_json(
        only: %i[id name vehicle_type min_cc max_cc min_seats max_seats min_weight max_weight usage_type
                 price coverage duration_months status]
      )
    )
  end
end
