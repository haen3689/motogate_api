require "prawn"

module InsuranceCertificate
  # Overlays policy data on top of the Lanexang Assurance certificate
  # template image (page 1 of 2 — page 2 is fixed terms/conditions with no
  # blanks to fill). The template is a flat scanned image, not a fillable
  # PDF form, so every field is positioned by pixel coordinate rather than
  # by form-field name.
  #
  # Coordinates below are measured against the template's native pixel
  # size (TEMPLATE_PX_W x TEMPLATE_PX_H) and converted to PDF points at
  # render time — see Generator#xy.
  class Generator
    TEMPLATE_PATH = Rails.root.join("app/assets/templates/insurance_certificate_lanexang.jpg")
    FONT_PATH = Rails.root.join("app/assets/fonts/NotoSansLao-Static.ttf")

    TEMPLATE_PX_W = 1785.0
    TEMPLATE_PX_H = 2526.0
    PAGE_W = 595.28 # A4 pt
    PAGE_H = 841.89

    VEHICLE_TYPE_CHECKBOX = {
      "motorcycle" => [390, 783],
      "car" => [810, 783],
      "van" => [1200, 783],
      "bus" => [245, 831],
      "pickup" => [810, 783],
      "suv" => [810, 783],
      "towtruck" => [470, 831],
      "trailer" => [1020, 831]
    }.freeze

    USAGE_CHECKBOX = {
      "ນຳໃຊ້ສ່ວນຕົວ" => [300, 871],
      "ນຳໃຊ້ທຸລະກິດ" => [545, 871]
    }.freeze

    def initialize(insurance)
      @insurance = insurance
      @vehicle = insurance.vehicle
      @user = @vehicle.user
    end

    def call
      Prawn::Document.generate(output_path, page_size: "A4", margin: 0) do |pdf|
        pdf.font_families.update("NotoSansLao" => { normal: FONT_PATH.to_s })
        pdf.font "NotoSansLao"

        pdf.image TEMPLATE_PATH.to_s, at: [0, PAGE_H], width: PAGE_W, height: PAGE_H

        draw_certificate_no(pdf)
        draw_declaration(pdf)
        draw_vehicle_info(pdf)
        draw_checkboxes(pdf)
        draw_period_and_premium(pdf)
      end
      output_path
    end

    private

    # Converts a coordinate measured on the template image (origin
    # top-left, in pixels) to a Prawn coordinate (origin bottom-left, in
    # points).
    def xy(px, py)
      [px * (PAGE_W / TEMPLATE_PX_W), PAGE_H - (py * (PAGE_H / TEMPLATE_PX_H))]
    end

    def text(pdf, str, px, py, size: 13)
      return if str.blank?

      pdf.draw_text str.to_s, at: xy(px, py), size: size
    end

    def checkmark(pdf, px, py, size: 13)
      pdf.draw_text "X", at: xy(px, py), size: size
    end

    # The template's own pre-printed certificate number belongs to this
    # one specimen image — cover it and print our own generated number so
    # every certificate we produce has a correct, unique number.
    def draw_certificate_no(pdf)
      pdf.fill_color "FFFF00"
      x, y = xy(1385, 172)
      pdf.fill_rectangle [x, y], 395 * (PAGE_W / TEMPLATE_PX_W), 28 * (PAGE_H / TEMPLATE_PX_H)
      pdf.fill_color "000000"
      text(pdf, certificate_no, 1420, 158, size: 14)
    end

    def draw_declaration(pdf)
      text(pdf, full_name, 470, 503)
      text(pdf, "ລາວ", 1525, 503)

      text(pdf, @user.village, 1000, 543)
      text(pdf, @user.district, 1400, 543)
      text(pdf, @user.province, 280, 583)
      text(pdf, @user.phone_number, 820, 583)
    end

    def draw_vehicle_info(pdf)
      text(pdf, @vehicle.brand, 580, 633)
      text(pdf, @vehicle.model, 1030, 633)
      text(pdf, @vehicle.year&.to_s, 1625, 633)

      text(pdf, @vehicle.color, 230, 673)
      text(pdf, @vehicle.engine_number, 630, 673)
      text(pdf, @vehicle.chassis_number, 1110, 673)

      text(pdf, @vehicle.plate_number, 310, 713)
      text(pdf, @vehicle.plate_type, 995, 713)
      text(pdf, @vehicle.province, 1480, 713)

      text(pdf, @vehicle.cc&.to_s, 330, 753, size: 11)
      text(pdf, @vehicle.seat_count&.to_s, 810, 753, size: 11)
      text(pdf, @vehicle.weight&.to_s, 1095, 753, size: 11)

      # Top-right summary box
      text(pdf, format_date(@insurance.start_date), 1600, 190, size: 9)
      text(pdf, format_date(@insurance.end_date), 1550, 225, size: 9)
      text(pdf, @vehicle.plate_number, 1550, 260, size: 9)
    end

    def draw_checkboxes(pdf)
      vt_coords = VEHICLE_TYPE_CHECKBOX[@vehicle.vehicle_type]
      checkmark(pdf, *vt_coords) if vt_coords

      usage_coords = USAGE_CHECKBOX[@vehicle.usage_type]
      checkmark(pdf, *usage_coords) if usage_coords

      # Always "new contract" — this app only ever issues fresh policies,
      # never renewals, so there's no prior-contract state to branch on.
      checkmark(pdf, 665, 900)
    end

    def draw_period_and_premium(pdf)
      text(pdf, format_date(@insurance.start_date), 410, 1893, size: 11)
      text(pdf, format_date(@insurance.start_date), 430, 1928, size: 11)
      text(pdf, format_date(@insurance.end_date), 420, 1963, size: 11)

      text(pdf, money(@insurance.amount), 1330, 1893, size: 11)
      text(pdf, money(@insurance.amount), 1250, 2038, size: 13)
    end

    def full_name
      [@user.first_name, @user.last_name].compact_blank.join(" ").presence || @user.name
    end

    def certificate_no
      "MG#{@insurance.created_at.strftime('%y')}-#{@insurance.id.to_s.rjust(6, '0')}"
    end

    def format_date(date)
      date&.strftime("%d/%m/%Y")
    end

    def money(amount)
      return nil if amount.blank?

      "#{amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse} ກີບ"
    end

    def output_path
      @output_path ||= Rails.root.join("tmp", "insurance_certificate_#{@insurance.id}.pdf")
    end
  end
end
