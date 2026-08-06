class VerificationsController < ApplicationController
  layout "verification"

  CHECK_DEFS = [
    { key: :license,      label: "ໃບຂັບຂີ",       subtitle: "Driver License" },
    { key: :registration, label: "ທະບຽນລົດ",      subtitle: "Car Registration" },
    { key: :road_tax,     label: "ຄ່າທາງ",        subtitle: "Road Tax" },
    { key: :inspection,   label: "ກວດກາເຕັກນິກ",  subtitle: "Technical Inspection" },
    { key: :insurance,    label: "ປະກັນໄພ",       subtitle: "Motor Insurance" },
  ].freeze

  # GET /verify/:token
  # Public page (no login) that a "QR CODE ເອກະສານ" scan opens. The token
  # is short-lived and scoped, so once it expires this always renders the
  # invalid/expired state instead of stale document data.
  def show
    payload = JwtService.decode(params[:token])
    raise "Invalid QR code" unless payload[:scope] == "verify"

    @user = User.find(payload[:user_id])
    @checked_at = Time.current

    if payload[:vehicle_id].present?
      @vehicle = @user.vehicles.find(payload[:vehicle_id])
      build_checks_for(@vehicle)
    else
      @vehicles = @user.vehicles.order(:plate_number)
      @license_status = status_for(@user.license_expiry_date)
      @vehicle_rows = @vehicles.map do |v|
        road_tax = v.road_taxes.order(expired_at: :desc).first
        insurance = v.insurances.order(end_date: :desc).first
        {
          vehicle: v,
          road_tax_status: status_for(road_tax&.expired_at),
          insurance_status: status_for(insurance&.end_date),
        }
      end
    end
    @valid = true
  rescue => e
    @valid = false
    @error_message = e.message == "Token expired" ? "QR ໝົດອາຍຸແລ້ວ" : "QR ບໍ່ຖືກຕ້ອງ"
  end

  STATUS_STYLE = {
    valid:   { label: "ຢືນຢັນ",        bg: "#DCFCE7", fg: "#16A34A" },
    expired: { label: "ໝົດອາຍຸ",       bg: "#FEE2E2", fg: "#DC2626" },
    missing: { label: "ຍັງບໍ່ມີຂໍ້ມູນ", bg: "#FEF3C7", fg: "#CA8A04" },
  }.freeze

  private

  # Builds @checks (one row per CHECK_DEFS entry, with a status/date/note)
  # plus @ok_count/@fail_count for the "4/5 OK" ratio badge and the
  # expired-item warning banners.
  def build_checks_for(vehicle)
    road_tax = vehicle.road_taxes.order(expired_at: :desc).first
    insurance = vehicle.insurances.order(end_date: :desc).first
    inspection = vehicle.inspections.order(appointment_at: :desc).first
    has_registration_photo = vehicle.registration_front.attached? || vehicle.registration_back.attached?

    inspection_status =
      if inspection.nil?
        :missing
      elsif inspection.status == "passed"
        :valid
      elsif inspection.status == "failed"
        :expired
      else
        :missing
      end

    values = {
      license:      { status: status_for(@user.license_expiry_date), date: @user.license_expiry_date },
      registration: { status: has_registration_photo ? :valid : :missing, date: vehicle.registration_expiry_date },
      road_tax:     { status: status_for(road_tax&.expired_at), date: road_tax&.expired_at },
      inspection:   { status: inspection_status, date: inspection&.appointment_at },
      insurance:    { status: status_for(insurance&.end_date), date: insurance&.end_date },
    }

    @checks = CHECK_DEFS.map { |d| d.merge(values[d[:key]]) }
    @ok_count = @checks.count { |c| c[:status] == :valid }
    @fail_count = @checks.size - @ok_count
  end

  def status_for(date)
    return :missing if date.blank?
    date_obj = date.respond_to?(:to_date) ? date.to_date : Date.parse(date.to_s)
    date_obj < Date.current ? :expired : :valid
  end
  helper_method :status_for

  def status_badge(status)
    s = STATUS_STYLE.fetch(status)
    style = "display:inline-flex;align-items:center;gap:4px;padding:4px 10px;border-radius:20px;" \
            "font-size:12px;font-weight:700;background:#{s[:bg]};color:#{s[:fg]};"
    %(<span style="#{style}">#{ERB::Util.html_escape(s[:label])}</span>).html_safe
  end
  helper_method :status_badge
end
