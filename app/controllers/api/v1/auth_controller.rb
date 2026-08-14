class Api::V1::AuthController < ApiController
  include Throttling

  skip_before_action :authenticate!, only: %i[request_otp verify_otp login_phone request_otp_debug]

  # POST /api/v1/auth/request_otp
  #
  # Unauthenticated and sends a real, billable Telbiz SMS, with no throttling
  # middleware anywhere in the stack — so it could be looped to run up the SMS
  # bill, or pointed at one number to harass its owner. Limited both per phone
  # number and per IP.
  def request_otp
    throttle!(
      bucket: "request_otp_phone",
      by: params[:phone_number].to_s,
      limit: 5,
      period: 1.hour,
      message: "ຂໍລະຫັດ OTP ຫຼາຍເກີນໄປ ກະລຸນາລອງໃໝ່ພາຍຫຼັງ"
    )
    throttle!(bucket: "request_otp_ip", limit: 20, period: 1.hour)

    user = User.find_or_initialize_by(phone_number: params[:phone_number])
    user.name = params[:name] if user.new_record?
    otp = user.generate_otp
    SendOtpSmsJob.perform_later(phone_number: user.phone_number, otp: otp)
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

    # Handing the OTP back in the response is a complete authentication bypass
    # for any phone number. It is off unless ALLOW_DEBUG is set, and the beta
    # runs with RAILS_ENV=production, so make every use loud enough to notice
    # in the logs if the variable is ever left on by accident.
    if Rails.env.production?
      Rails.logger.warn(
        "[Auth] request_otp_debug returned a plaintext OTP for " \
        "#{params[:phone_number]} — ALLOW_DEBUG is enabled in production. " \
        "This bypasses authentication entirely; unset it."
      )
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

  # POST /api/v1/auth/login_phone
  #
  # This used to take a phone number and nothing else, trusting that the
  # client had checked the OTP with Telbiz itself, and hand back a session
  # token. A client-side check is not a check: anyone could POST any phone
  # number straight to this endpoint and receive a valid token for that
  # account — and JwtService.encode issues it with no expiry and there is no
  # revocation list, so the token was good forever. It also created accounts
  # for numbers that had never been proven.
  #
  # The OTP is now verified server-side, exactly as #verify_otp does. The
  # phone must already exist (via #request_otp), so this no longer mints
  # accounts for unproven numbers.
  #
  # ROLLOUT: app builds that predate this send no :otp and will fail here. If
  # login breaks after deploying, set ALLOW_UNVERIFIED_PHONE_LOGIN=true in the
  # Render dashboard to restore the old behaviour without a redeploy, ship the
  # updated app, then remove the variable. Leaving it on leaves the account
  # takeover hole wide open — treat it as a rollback lever, not a setting.
  def login_phone
    if params[:otp].blank? && ENV["ALLOW_UNVERIFIED_PHONE_LOGIN"] == "true"
      Rails.logger.warn(
        "[Auth] login_phone accepted without OTP for #{params[:phone_number]} " \
        "— ALLOW_UNVERIFIED_PHONE_LOGIN is enabled. This is an account " \
        "takeover risk; unset it once the OTP-sending app build has shipped."
      )
      user = User.find_or_initialize_by(phone_number: params[:phone_number])
      user.verified = true
      user.save!
      return render_success({ token: JwtService.encode(user.id), user: user_json(user) })
    end

    user = User.find_by!(phone_number: params[:phone_number])
    user.verify_otp!(params[:otp])
    render_success({ token: JwtService.encode(user.id), user: user_json(user) })
  rescue ActiveRecord::RecordNotFound
    render_error("Phone number not found", status: :not_found)
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
    # Two targeted streams instead of the old global "user_updates" one — this
    # payload carries the user's ID number, licence number and signed document
    # URLs, so it must not go to whoever happens to be connected. The owner
    # gets their own stream; ActiveAdmin's header toast gets the admin-only
    # firehose (see UserUpdatesChannel).
    ActionCable.server.broadcast("user_updates_#{current_user.id}", { user: data })
    ActionCable.server.broadcast("admin_user_updates", { user: data })
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
                  :license_name, :license_number, :license_type, :license_expiry_date)
  end

  def user_json(user)
    data = user.as_json(only: %i[id phone_number name first_name last_name gender date_of_birth
                                  province district village id_type id_number id_expiry_date
                                  license_name license_number license_type license_expiry_date verified created_at])
    data[:id_card_image_url]  = user.id_card_image.attached?  ? url_for(user.id_card_image)  : nil
    data[:license_image_url]  = user.license_image.attached?  ? url_for(user.license_image)  : nil
    data[:profile_image_url]  = user.profile_image.attached?  ? url_for(user.profile_image)  : nil
    data[:unread_announcements_count] =
      Announcement.active.where("created_at > ?", user.last_announcements_seen_at || Time.at(0)).count
    data
  end
end
