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

    if source == 'external_upload'
      # The whole premise of this path is "I already paid, here's the proof",
      # yet the proof image was optional — so the endpoint would happily
      # record a paid road tax backed by nothing at all.
      if params[:proof_image].blank?
        return render_error("ກະລຸນາແນບຮູບໃບຮັບເງິນ", status: :unprocessable_entity)
      end

      tax = build_external_upload_tax(vehicle)
      return render_error("ບໍ່ພົບອັດຕາຄ່າທາງສຳລັບລົດຄັນນີ້ ກະລຸນາຕິດຕໍ່ບໍລິຫານ") if tax.nil?

      if tax.save
        log_transaction!(
          type: "road_tax",
          amount: tax.amount.to_f + tax.service_fee.to_f,
          reference: vehicle.plate_number,
          description: "ຄ່າທາງ ປີ #{tax.tax_year} - #{vehicle.plate_number}"
        )
        render_success(tax_json(tax), status: :created)
      else
        render_error(tax.errors.full_messages.join(", "))
      end
    else
      create_app_payment(vehicle)
    end
  rescue ActiveRecord::RecordNotFound
    render_error("ບໍ່ພົບລົດ", status: :not_found)
  end

  private

  # Creates the (pending) tax record and its BCEL OnePay Payment together —
  # the tax only flips to "paid" once Payment#mark_paid! fires from the
  # PubNub callback (see RoadTax#mark_paid_from_payment!).
  def create_app_payment(vehicle)
    rate = RoadTaxRate.for_vehicle(vehicle)
    return render_error("ບໍ່ພົບອັດຕາຄ່າທາງສຳລັບລົດຄັນນີ້ ກະລຸນາຕິດຕໍ່ບໍລິຫານ") unless rate

    tax = payment = nil
    RoadTax.transaction do
      tax = vehicle.road_taxes.create!(
        tax_year: params[:tax_year],
        amount: rate.price,
        status: 'pending',
        source: 'app_payment',
        expired_at: params[:expired_at]
      )
      payment = tax.payments.create!(
        amount: rate.price,
        terminal_id: "MG-ROADTAX",
        description: "AutoPass Road Tax #{params[:tax_year]}",
        expires_at: 15.minutes.from_now
      )
      payment.update!(invoice_id: payment.uuid)
    end
    render_success(tax_json(tax).merge(payment: payment.as_app_json), status: :created)
  rescue ActiveRecord::RecordInvalid => e
    render_error(e.record.errors.full_messages.join(", "))
  end

  # Self-declared: the user says they paid at a transport office. Nothing here
  # is verified against the transport department, and a traffic officer's QR
  # check grades road tax on expired_at alone — so every field the client used
  # to control was a way to mint a green "valid until <whenever>" badge for
  # free. The record is still created immediately (no admin queue, per the
  # product decision above); it just can no longer be conjured out of nothing.
  def build_external_upload_tax(vehicle)
    rate = RoadTaxRate.for_vehicle(vehicle)
    base_amount = rate&.price || 0
    tax = vehicle.road_taxes.build(
      tax_year: params[:tax_year],
      amount: base_amount,
      service_fee: RoadTaxSetting.current.compute_fee(base_amount),
      status: 'paid',
      source: 'external_upload',
      # paid_at is when they say they paid — it cannot be in the future, and
      # defaults to now rather than to nil.
      paid_at: external_paid_at,
      # Derived from the declared tax year, never taken from the client, which
      # previously accepted things like 2099-12-31.
      expired_at: external_expiry_for(params[:tax_year])
    )
    tax.proof_image.attach(params[:proof_image])
    tax
  end

  def external_paid_at
    supplied = params[:paid_at].present? ? Time.zone.parse(params[:paid_at].to_s) : nil
    return Time.current if supplied.nil? || supplied > Time.current

    supplied
  rescue ArgumentError
    Time.current
  end

  # Lao road tax runs to the end of the declared tax year. Falls back to the
  # current year when the client sends something unparseable.
  def external_expiry_for(tax_year)
    year = tax_year.to_i
    year = Date.current.year unless year.between?(2000, Date.current.year + 1)
    Date.new(year, 12, 31).end_of_day
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
