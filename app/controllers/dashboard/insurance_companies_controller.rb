class Dashboard::InsuranceCompaniesController < Dashboard::BaseController
  def index
    @companies = InsuranceCompany.includes(:insurance_packages).order(:name)
  end

  def show
    @company = InsuranceCompany.includes(:insurance_packages).find(params[:id])
  end
end
