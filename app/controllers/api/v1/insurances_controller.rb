class Api::V1::InsurancesController < ApiController
  def index
    insurances = Insurance.joins(:vehicle).where(vehicles: { user_id: current_user.id })
    render_success(insurances.order(created_at: :desc).map { |i| insurance_json(i) })
  end

  def show
    insurance = user_insurances.find(params[:id])
    render_success(insurance_json(insurance))
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບຂໍ້ມູນ", status: :not_found)
  end

  def create
    vehicle = current_user.vehicles.find(params[:vehicle_id])
    insurance = vehicle.insurances.build(insurance_params)
    if insurance.save
      log_transaction!(
        type: "insurance",
        amount: insurance.amount,
        reference: vehicle.plate_number,
        description: "ປະກັນໄພ #{insurance.package} - #{vehicle.plate_number}"
      )
      render_success(insurance_json(insurance), status: :created)
    else
      render_error(insurance.errors.full_messages.join(", "))
    end
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບລົດ", status: :not_found)
  end

  # Lets the user attach a photo of their physical policy document to an
  # insurance they already have on file (e.g. from the ຮູບພາບ gallery) —
  # separate from `create` since the document is usually only available
  # after the policy has actually been issued.
  def upload_document
    insurance = user_insurances.find(params[:id])
    if params[:document_image].present?
      insurance.document_image.attach(params[:document_image])
      render_success(insurance_json(insurance))
    else
      render_error("ກະລຸນາເລືອກຮູບພາບ")
    end
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບຂໍ້ມູນ", status: :not_found)
  end

  private

  def user_insurances
    Insurance.joins(:vehicle).where(vehicles: { user_id: current_user.id })
  end

  def insurance_params
    params.permit(:company, :package, :amount, :status, :start_date, :end_date)
  end

  def insurance_json(i)
    i.as_json.merge(
      document_image_url: i.document_image.attached? ? url_for(i.document_image) : nil
    )
  end
end
