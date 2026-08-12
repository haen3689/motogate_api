class Api::V1::VehiclesController < ApiController
  before_action :set_owned_vehicle, only: %i[update destroy share unshare pay_fee]
  before_action :set_accessible_vehicle, only: %i[show]

  def index
    owned  = current_user.vehicles.map { |v| vehicle_json(v, owner: true) }
    shared = current_user.shared_vehicles.map { |v| vehicle_json(v, owner: false) }
    render_success(owned + shared)
  end

  def show
    render_success(vehicle_json(@vehicle, owner: @vehicle.user_id == current_user.id))
  end

  def create
    vehicle = current_user.vehicles.build(vehicle_params)
    vehicle.registration_front.attach(params[:registration_front]) if params[:registration_front].present?
    vehicle.registration_back.attach(params[:registration_back])   if params[:registration_back].present?
    vehicle.front_photo.attach(params[:front_photo])               if params[:front_photo].present?
    vehicle.transport_booklet.attach(params[:transport_booklet])   if params[:transport_booklet].present?
    if vehicle.save
      render_success(vehicle_json(vehicle, owner: true), status: :created)
    else
      render_error(vehicle.errors.full_messages.join(", "))
    end
  end

  def update
    if @vehicle.update(vehicle_params)
      @vehicle.registration_front.attach(params[:registration_front]) if params[:registration_front].present?
      @vehicle.registration_back.attach(params[:registration_back])   if params[:registration_back].present?
      @vehicle.front_photo.attach(params[:front_photo])               if params[:front_photo].present?
      @vehicle.transport_booklet.attach(params[:transport_booklet])   if params[:transport_booklet].present?
      render_success(vehicle_json(@vehicle, owner: true))
    else
      render_error(@vehicle.errors.full_messages.join(", "))
    end
  end

  def destroy
    @vehicle.destroy
    render_success({ message: "Vehicle deleted" })
  end

  # POST /api/v1/vehicles/:id/share
  # Grants a registered user (identified by phone number) read-only access
  # to this vehicle. Only the owner can share.
  def share
    phone = params[:phone_number].to_s.strip
    return render_error("ກະລຸນາປ້ອນເບີໂທລະສັບ", status: :bad_request) if phone.blank?

    target = User.find_by(phone_number: phone)
    return render_error("ບໍ່ພົບຜູ້ໃຊ້ທີ່ລົງທະບຽນເບີນີ້ໃນແອັບ", status: :not_found) unless target
    return render_error("ບໍ່ສາມາດເພີ່ມຕົນເອງໄດ້", status: :unprocessable_entity) if target.id == current_user.id

    share = @vehicle.vehicle_shares.find_or_initialize_by(user: target)
    if share.persisted?
      render_error("ຜູ້ໃຊ້ນີ້ຖືກເພີ່ມເປັນຜູ້ໃຊ້ສຳຮອງແລ້ວ")
    elsif share.save
      render_success(vehicle_json(@vehicle, owner: true), status: :created)
    else
      render_error(share.errors.full_messages.join(", "))
    end
  end

  # DELETE /api/v1/vehicles/:id/share/:user_id
  def unshare
    @vehicle.vehicle_shares.find_by(user_id: params[:user_id])&.destroy
    render_success(vehicle_json(@vehicle, owner: true))
  end

  # POST /api/v1/vehicles/:id/pay_fee — creates a pending BCEL OnePay
  # Payment for the one-time registration fee. fee_paid only flips true
  # once Vehicle#mark_paid_from_payment! fires from the PubNub callback.
  def pay_fee
    return render_error("ຈ່າຍຄ່າທຳນຽມແລ້ວ") if @vehicle.fee_paid?

    payment = @vehicle.payments.create!(
      amount: Vehicle::REGISTRATION_FEE,
      terminal_id: "MG-VEHICLEFEE",
      description: "MotoGate Vehicle Registration Fee",
      expires_at: 15.minutes.from_now
    )
    payment.update!(invoice_id: payment.uuid)
    render_success(payment.as_app_json, status: :created)
  end

  private

  def set_owned_vehicle
    @vehicle = current_user.vehicles.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error("Vehicle not found", status: :not_found)
  end

  def set_accessible_vehicle
    @vehicle = Vehicle.find(params[:id])
    unless @vehicle.user_id == current_user.id || @vehicle.shared_users.exists?(current_user.id)
      raise ActiveRecord::RecordNotFound
    end
  rescue ActiveRecord::RecordNotFound
    render_error("Vehicle not found", status: :not_found)
  end

  # fee_paid is intentionally not permitted here — it can only be flipped
  # by Vehicle#mark_paid_from_payment! once BCEL actually confirms payment
  # (see #pay_fee), never directly by the client.
  def vehicle_params
    params.permit(:plate_number, :plate_type, :brand, :model, :year, :color, :vehicle_type,
                  :engine_number, :chassis_number, :cc, :province, :usage_type,
                  :owner_name, :fuel_type, :seat_count, :axle_count, :cylinder_count, :weight,
                  :registration_expiry_date)
  end

  def vehicle_json(v, owner:)
    v.as_json.merge(
      registration_front_url: v.registration_front.attached? ? url_for(v.registration_front) : nil,
      registration_back_url:  v.registration_back.attached?  ? url_for(v.registration_back)  : nil,
      front_photo_url:        v.front_photo.attached?        ? url_for(v.front_photo)        : nil,
      transport_booklet_url:  v.transport_booklet.attached?  ? url_for(v.transport_booklet)  : nil,
      is_owner: owner,
      shared_users: owner ? v.shared_users.map { |u| shared_user_json(u) } : [],
    )
  end

  def shared_user_json(u)
    {
      id: u.id,
      name: [u.first_name, u.last_name].compact_blank.join(" ").presence || u.name,
      phone_number: u.phone_number,
    }
  end
end
