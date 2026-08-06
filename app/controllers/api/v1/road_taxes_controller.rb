class Api::V1::RoadTaxesController < ApiController
  def index
    render_success(user_road_taxes.order(created_at: :desc).map { |t| tax_json(t) })
  end

  def show
    tax = user_road_taxes.find(params[:id])
    render_success(tax_json(tax))
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບຂໍ້ມູນ", status: :not_found)
  end

  # Two sources:
  # - app_payment: price is computed server-side from RoadTaxRate — the client
  #   cannot set the amount, it just picks the vehicle + tax year.
  # - external_upload: the user already paid at a physical transport office and
  #   is just uploading proof; recorded as paid immediately (no admin review),
  #   kept as its own source so a future real transport-department integration
  #   can distinguish/reconcile app-collected vs externally-paid records.
  def create
    vehicle = current_user.vehicles.find(params[:vehicle_id])
    source = RoadTax::SOURCES.include?(params[:source]) ? params[:source] : 'app_payment'

    tax = if source == 'external_upload'
      build_external_upload_tax(vehicle)
    else
      build_app_payment_tax(vehicle)
    end

    if tax.nil?
      render_error("ບໍ່ພົບອັດຕາຄ່າທາງສຳລັບລົດຄັນນີ້ ກະລຸນາຕິດຕໍ່ບໍລິຫານ")
    elsif tax.save
      render_success(tax_json(tax), status: :created)
    else
      render_error(tax.errors.full_messages.join(", "))
    end
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບລົດ", status: :not_found)
  end

  private

  def build_app_payment_tax(vehicle)
    rate = RoadTaxRate.for_vehicle(vehicle)
    return nil unless rate

    vehicle.road_taxes.build(
      tax_year: params[:tax_year],
      amount: rate.price,
      status: 'paid',
      source: 'app_payment',
      expired_at: params[:expired_at]
    )
  end

  def build_external_upload_tax(vehicle)
    rate = RoadTaxRate.for_vehicle(vehicle)
    base_amount = rate&.price || 0
    tax = vehicle.road_taxes.build(
      tax_year: params[:tax_year],
      amount: base_amount,
      service_fee: RoadTaxSetting.current.compute_fee(base_amount),
      status: 'paid',
      source: 'external_upload',
      paid_at: params[:paid_at],
      expired_at: params[:expired_at]
    )
    tax.proof_image.attach(params[:proof_image]) if params[:proof_image].present?
    tax
  end

  def user_road_taxes
    RoadTax.joins(:vehicle).where(vehicles: { user_id: current_user.id })
  end

  def tax_json(tax)
    tax.as_json.merge(
      proof_image_url: tax.proof_image.attached? ? url_for(tax.proof_image) : nil
    )
  end
end
