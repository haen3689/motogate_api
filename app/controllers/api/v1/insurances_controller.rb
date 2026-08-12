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

  # Price comes from the InsurancePackage the client picked (looked up
  # server-side by company + package name) — never from the client's own
  # `amount`. The insurance stays "pending" until BCEL confirms the
  # payment; see Insurance#mark_paid_from_payment!.
  def create
    vehicle = current_user.vehicles.find(params[:vehicle_id])
    company = InsuranceCompany.active.find_by(name: params[:company])
    return render_error("ບໍ່ພົບບໍລິສັດປະກັນໄພ") unless company

    package = company.insurance_packages.active.find_by(name: params[:package])
    return render_error("ບໍ່ພົບແພັກເກັດປະກັນໄພ") unless package

    insurance = payment = nil
    Insurance.transaction do
      insurance = vehicle.insurances.create!(
        insurance_company: company,
        company: company.name,
        package: package.name,
        amount: package.price,
        status: 'pending'
      )
      payment = insurance.payments.create!(
        amount: package.price,
        terminal_id: "MG-INSURANCE",
        description: "MotoGate Insurance #{package.name}",
        expires_at: 15.minutes.from_now
      )
      payment.update!(invoice_id: payment.uuid)
    end
    render_success(insurance_json(insurance).merge(payment: payment.as_app_json), status: :created)
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບລົດ", status: :not_found)
  rescue ActiveRecord::RecordInvalid => e
    render_error(e.record.errors.full_messages.join(", "))
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

  # GET /api/v1/insurances/:id/certificate — generates the filled Lanexang
  # Assurance certificate PDF on demand (not stored; cheap to regenerate,
  # and always reflects the current record).
  def certificate
    insurance = user_insurances.find(params[:id])
    return render_error("ໃບຢັ້ງຢືນຈະພ້ອມຫຼັງຈາກຊຳລະເງິນສຳເລັດ") unless insurance.status == "active"

    path = InsuranceCertificate::Generator.new(insurance).call
    send_file path, type: "application/pdf", disposition: "inline",
                     filename: "motogate-insurance-#{insurance.id}.pdf"
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບຂໍ້ມູນ", status: :not_found)
  end

  private

  def user_insurances
    Insurance.joins(:vehicle).where(vehicles: { user_id: current_user.id })
  end

  def insurance_json(i)
    i.as_json.merge(
      document_image_url: i.document_image.attached? ? url_for(i.document_image) : nil
    )
  end
end
