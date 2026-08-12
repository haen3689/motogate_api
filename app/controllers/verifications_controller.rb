class VerificationsController < ApplicationController
  layout "verification"

  CHECK_DEFS = [
    { key: :license,      label: "ໃບຂັບຂີ່",       subtitle: "Driver License" },
    { key: :registration, label: "ທະບຽນລົດ",      subtitle: "Car Registration" },
    { key: :road_tax,     label: "ຄ່າທາງ",        subtitle: "Road Tax" },
    { key: :inspection,   label: "ກວດກາເຕັກນິກ",  subtitle: "Technical Inspection" },
    { key: :insurance,    label: "ປະກັນໄພ",       subtitle: "Motor Insurance" },
  ].freeze

  STATUS_STYLE = {
    valid:   { label: "ຢືນຢັນ",        bg: "#DCFCE7", fg: "#16A34A" },
    expired: { label: "ໝົດອາຍຸ",       bg: "#FEE2E2", fg: "#DC2626" },
    missing: { label: "ຍັງບໍ່ມີຂໍ້ມູນ", bg: "#FEF3C7", fg: "#CA8A04" },
  }.freeze

  REMARK_STYLE = {
    valid:   "ປົກກະຕິ",
    expired: "ໝົດອາຍຸ (ລໍຖ້າຕໍ່)",
    missing: "ຍັງບໍ່ມີຂໍ້ມູນ",
  }.freeze

  RECOMMENDATIONS = {
    license:      "ໃບຂັບຂີ່ຂອງທ່ານໝົດອາຍຸ ຫຼື ຍັງບໍ່ມີຂໍ້ມູນ. ກະລຸນາຕໍ່ອາຍຸ ຫຼື ອັບໂຫລດໃບຂັບຂີ່ເຂົ້າລະບົບ.",
    registration: "ຍັງບໍ່ໄດ້ອັບໂຫລດຮູບພາບທະບຽນລົດ. ກະລຸນາອັບໂຫລດເອກະສານທະບຽນລົດເຂົ້າລະບົບ.",
    road_tax:     "ຄ່າທາງຂອງພາຫະນະຄັນນີ້ໝົດອາຍຸ ຫຼື ຍັງບໍ່ໄດ້ຈ່າຍ. ກະລຸນາດຳເນີນການຈ່າຍຄ່າທາງ.",
    inspection:   "ພາຫະນະຄັນນີ້ຍັງບໍ່ໄດ້ກວດກາເຕັກນິກ ຫຼື ບໍ່ຜ່ານການກວດກາ. ກະລຸນານັດໝາຍກວດກາເຕັກນິກໃໝ່.",
    insurance:    "ປະກັນໄພຂອງພາຫະນະຄັນນີ້ໄດ້ໝົດອາຍຸແລ້ວ. ກະລຸນາດຳເນີນການຕໍ່ອາຍຸປະກັນໄພ ແລະ ອັບໂຫຼດເອກະສານສະບັບໃໝ່ເຂົ້າລະບົບ.",
  }.freeze

  before_action :load_verification

  # GET /verify/:token
  # Public page (no login) that a "QR CODE ເອກະສານ" scan opens. The token
  # is short-lived and scoped, so once it expires this always renders the
  # invalid/expired state instead of stale document data.
  def show
  end

  # GET /verify/:token/report
  # Printable "Tabular Audit Report" for the Export PDF button — same
  # data as `show`, laid out for browser print-to-PDF instead of mobile
  # viewing.
  def report
    render layout: "print"
  end

  private

  # Loads the token payload and builds @vehicle_reports (one entry per
  # vehicle, each with its own @checks/@ok_count/@fail_count) shared by
  # both `show` and `report`. Single-vehicle tokens also get top-level
  # @checks/@ok_count/@fail_count for `show.html.erb`'s existing layout.
  def load_verification
    payload = JwtService.decode(params[:token])
    raise "Invalid QR code" unless payload[:scope] == "verify"

    @user = User.find(payload[:user_id])
    @checked_at = Time.current
    @ref = params[:token].to_s.last(8).upcase
    @license_status = status_for(@user.license_expiry_date)

    vehicles =
      if payload[:vehicle_id].present?
        @vehicle = @user.vehicles.find(payload[:vehicle_id])
        [@vehicle]
      else
        @vehicles = @user.vehicles.order(:plate_number)
      end

    @vehicle_reports = vehicles.map { |v| { vehicle: v, **checks_for(v) } }

    if @vehicle
      r = @vehicle_reports.first
      @checks = r[:checks]
      @ok_count = r[:ok_count]
      @fail_count = r[:fail_count]
    else
      @vehicle_rows = vehicles.map do |v|
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

  # One vehicle's checks (one row per CHECK_DEFS entry, with a
  # status/date) plus its ok_count/fail_count for the "X/5" ratio.
  def checks_for(vehicle)
    road_tax = vehicle.road_taxes.order(expired_at: :desc).first
    insurance = vehicle.insurances.order(end_date: :desc).first
    inspection = vehicle.inspections.order(appointment_at: :desc).first
    registration_urls = [vehicle.registration_front, vehicle.registration_back]
                         .select(&:attached?).map { |a| url_for(a) }
    has_registration_photo = registration_urls.any?
    license_urls = @user.license_image.attached? ? [url_for(@user.license_image)] : []
    no_photos = []

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

    registration_status =
      if !has_registration_photo
        :missing
      elsif vehicle.registration_expiry_date.present? && vehicle.registration_expiry_date < Date.current
        :expired
      else
        :valid
      end

    values = {
      license:      { status: @license_status, date: @user.license_expiry_date, image_urls: license_urls },
      registration: { status: registration_status, date: vehicle.registration_expiry_date, image_urls: registration_urls },
      road_tax:     { status: status_for(road_tax&.expired_at), date: road_tax&.expired_at, image_urls: no_photos },
      inspection:   { status: inspection_status, date: inspection&.appointment_at, image_urls: no_photos },
      insurance:    { status: status_for(insurance&.end_date), date: insurance&.end_date, image_urls: no_photos },
    }

    checks = CHECK_DEFS.map do |d|
      row = d.merge(values[d[:key]])
      row[:remark] = REMARK_STYLE.fetch(row[:status])
      row[:recommendation] = RECOMMENDATIONS.fetch(d[:key]) if row[:status] != :valid
      row
    end
    ok_count = checks.count { |c| c[:status] == :valid }
    { checks: checks, ok_count: ok_count, fail_count: checks.size - ok_count }
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

  def status_label(status)
    STATUS_STYLE.fetch(status)[:label]
  end
  helper_method :status_label

  VEHICLE_TYPE_LABELS = {
    "motorcycle" => "ລົດຈັກ", "car" => "ລົດເກັ່ງ", "pickup" => "ລົດກະບະ",
    "suv" => "ລົດຈິບ", "van" => "ລົດຕູ້", "bus" => "ລົດເມ",
    "towtruck" => "ລົດລາກ", "trailer" => "ລົດພ່ວງ",
  }.freeze

  def vehicle_type_label(type)
    VEHICLE_TYPE_LABELS.fetch(type, type.presence || "—")
  end
  helper_method :vehicle_type_label

  # Resolves a vehicle's `plate_type` (a PlateType#plate_code, e.g. "ຈ2")
  # to its full name (e.g. "ເອກະຊົນ ສ່ວນຕົວ") — this is the "ເປົ້າໝາຍການ
  # ນຳໃຊ້ລົດ" classification (private / company / police / military /
  # embassy / UN, etc).
  def plate_type_label(code)
    return "—" if code.blank?
    PlateType.find_by(plate_code: code)&.name || code
  end
  helper_method :plate_type_label
end
