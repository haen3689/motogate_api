class Api::V1::AuthController < ApiController
  skip_before_action :authenticate!, only: %i[request_otp verify_otp login_phone request_otp_debug]

  # POST /api/v1/auth/request_otp
  def request_otp
    user = User.find_or_initialize_by(phone_number: params[:phone_number])
    user.name = params[:name] if user.new_record?
    otp = user.generate_otp
    TelbizSmsService.send_otp(phone_number: user.phone_number, otp: otp)
    render_success({ message: "OTP sent", phone_number: user.phone_number })
  rescue => e
    render_error(e.message)
  end

  # GET /api/v1/auth/request_otp_debug?phone_number=+85620...  
  # Debug helper: generates OTP but does NOT send SMS. Returns the OTP
  # in the response only when ALLOW_DEBUG env var is 'true'.
  def request_otp_debug
    unless ENV['ALLOW_DEBUG'] == 'true'
      return render_error('Debug endpoint disabled', status: :forbidden)
    end

    phone = params[:phone_number]
    if phone.blank?
      return render_error('phone_number required', status: :bad_request)
    end

    user = User.find_or_initialize_by(phone_number: phone)
    user.name = params[:name] if user.new_record?
    otp = user.generate_otp
    # Intentionally do NOT call TelbizSmsService here — debug only
    render_success({ message: 'OTP generated (debug)', phone_number: user.phone_number, otp: otp })
  rescue => e
    render_error(e.message)
  end

  # POST /api/v1/auth/verify_otp
  def verify_otp
    user = User.find_by!(phone_number: params[:phone_number])
    user.verify_otp!(params[:otp])
    token = JwtService.encode(user.id)
    render_success({ token: token, user: user_json(user) })
  rescue ActiveRecord::RecordNotFound
    render_error("Phone number not found", status: :not_found)
  rescue => e
    render_error(e.message)
  end

  # GET /api/v1/auth/me
  def me
    render_success(user_json(current_user))
  end

  # POST /api/v1/auth/login_phone  (Telbiz OTP verified on client)
  def login_phone
    user = User.find_or_initialize_by(phone_number: params[:phone_number])
    user.verified = true
    user.save!
    token = JwtService.encode(user.id)
    render_success({ token: token, user: user_json(user) })
  rescue => e
    render_error(e.message)
  end

  # PUT /api/v1/auth/profile
  def profile
    current_user.update!(profile_params)
    current_user.id_card_image.attach(params[:id_card_image])   if params[:id_card_image].present?
    current_user.license_image.attach(params[:license_image])   if params[:license_image].present?
    current_user.profile_image.attach(params[:profile_image])   if params[:profile_image].present?
    data = user_json(current_user)
    ActionCable.server.broadcast("user_updates", { user: data })
    render_success({ user: data })
  rescue => e
    render_error(e.message)
  end

  # POST /api/v1/auth/register_device
  def register_device
    token    = params.require(:fcm_token)
    platform = params[:platform] || "android"
    current_user.update!(fcm_token: token, platform: platform)
    render_success({ message: "Device registered" })
  rescue => e
    render_error(e.message)
  end

  # POST /api/v1/auth/verify_token
  # Issues a short-lived, single-purpose token for the "QR CODE ເອກະສານ"
  # feature. Scoped to `verify` so it can't be used to call the regular
  # authenticated API even if it leaks, and expires quickly so a
  # screenshotted QR can't be reused indefinitely.
  VERIFY_TOKEN_TTL = 5.minutes

  def verify_token
    extra = { scope: "verify" }
    if params[:vehicle_id].present?
      vehicle = current_user.vehicles.find(params[:vehicle_id])
      extra[:vehicle_id] = vehicle.id
    end
    expires_at = VERIFY_TOKEN_TTL.from_now
    token = JwtService.encode(current_user.id, expiry: VERIFY_TOKEN_TTL, extra: extra)
    render_success({ token: token, expires_at: expires_at.iso8601 })
  rescue ActiveRecord::RecordNotFound
    render_error("Vehicle not found", status: :not_found)
  rescue => e
    render_error(e.message)
  end

  private

  def profile_params
    params.permit(:name, :first_name, :last_name, :gender, :date_of_birth,
                  :province, :district, :village,
                  :id_type, :id_number, :id_expiry_date,
                  :license_number, :license_type, :license_expiry_date)
  end

  def user_json(user)
    data = user.as_json(only: %i[id phone_number name first_name last_name gender date_of_birth
                                  province district village id_type id_number id_expiry_date
                                  license_number license_type license_expiry_date verified created_at])
    data[:id_card_image_url]  = user.id_card_image.attached?  ? url_for(user.id_card_image)  : nil
    data[:license_image_url]  = user.license_image.attached?  ? url_for(user.license_image)  : nil
    data[:profile_image_url]  = user.profile_image.attached?  ? url_for(user.profile_image)  : nil
    data[:unread_announcements_count] =
      Announcement.active.where("created_at > ?", user.last_announcements_seen_at || Time.at(0)).count
    data
  end
end
