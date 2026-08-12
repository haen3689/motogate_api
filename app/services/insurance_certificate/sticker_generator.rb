require "prawn"

module InsuranceCertificate
  # A small standalone PDF containing just the certificate's summary box
  # (cert no / inception / expiry / plate) — meant to be printed as a
  # windshield sticker separate from the full 2-page certificate.
  class StickerGenerator
    TEMPLATE_PATH = Rails.root.join("app/assets/templates/insurance_certificate_sticker_v2.png")
    FONT_PATH = Rails.root.join("app/assets/fonts/NotoSansLao-Static.ttf")

    TEMPLATE_PX_W = 1600.0
    TEMPLATE_PX_H = 2263.0
    PAGE_W = 595.28
    PAGE_H = PAGE_W * (TEMPLATE_PX_H / TEMPLATE_PX_W)
    SCALE = PAGE_W / TEMPLATE_PX_W

    def initialize(insurance)
      @insurance = insurance
      @vehicle = insurance.vehicle
    end

    def call
      Prawn::Document.generate(output_path, page_size: [PAGE_W, PAGE_H], margin: 0) do |pdf|
        pdf.font_families.update("NotoSansLao" => { normal: FONT_PATH.to_s })
        pdf.font "NotoSansLao"

        pdf.image TEMPLATE_PATH.to_s, at: [0, PAGE_H], width: PAGE_W, height: PAGE_H

        text(pdf, certificate_no, 620, 1105, size: 13)
        text(pdf, format_date(@insurance.start_date), 620, 1249, size: 13)
        text(pdf, format_date(@insurance.end_date), 620, 1389, size: 13)
        text(pdf, @vehicle.plate_number, 620, 1581, size: 13)
      end
      output_path
    end

    private

    def xy(px, py)
      [px * SCALE, PAGE_H - (py * SCALE)]
    end

    def text(pdf, str, px, py, size:)
      return if str.blank?

      pdf.fill_color "FFFFFF"
      pdf.draw_text str.to_s, at: xy(px, py), size: size
    end

    def certificate_no
      @insurance.certificate_number
    end

    def format_date(date)
      date&.strftime("%d/%m/%Y")
    end

    def output_path
      @output_path ||= Rails.root.join("tmp", "insurance_sticker_#{@insurance.id}.pdf")
    end
  end
end
