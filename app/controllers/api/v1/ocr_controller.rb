require 'net/http'
require 'json'
require 'base64'

class Api::V1::OcrController < ApiController
  include Throttling

  # OCR runs during onboarding, before the user has an account, so it cannot
  # require authentication. That makes it an open proxy to Google Vision billed
  # to GOOGLE_VISION_API_KEY — anyone could loop it and run up the bill. Rate
  # limited per IP instead, with a size cap so a single call can't be enormous.
  skip_before_action :authenticate!

  MAX_IMAGE_BYTES = 8.megabytes
  SCANS_PER_HOUR = 20

  def scan
    throttle!(
      bucket: "ocr_scan",
      limit: SCANS_PER_HOUR,
      period: 1.hour,
      message: "ສະແກນຫຼາຍເກີນໄປ ກະລຸນາລອງໃໝ່ພາຍຫຼັງ"
    )

    image = params[:image]
    return render_error('No image provided') unless image.present?
    unless image.respond_to?(:read)
      return render_error('Invalid image upload')
    end
    if image.respond_to?(:size) && image.size.to_i > MAX_IMAGE_BYTES
      return render_error('Image too large')
    end

    api_key = ENV['GOOGLE_VISION_API_KEY']
    return render_error('Vision API key not configured') unless api_key.present?

    image_data = Base64.strict_encode64(image.read)

    uri = URI("https://vision.googleapis.com/v1/images:annotate?key=#{api_key}")
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl    = true
    http.read_timeout = 15

    req = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    req.body = {
      requests: [{
        image: { content: image_data },
        features: [{ type: 'TEXT_DETECTION', maxResults: 1 }],
        imageContext: { languageHints: %w[lo th en] }
      }]
    }.to_json

    res  = http.request(req)
    body = JSON.parse(res.body)

    if body['error']
      return render_error("Vision API error: #{body['error']['message']}")
    end

    text = body.dig('responses', 0, 'textAnnotations', 0, 'description') || ''
    render json: { success: true, data: { text: text } }
  rescue => e
    render_error("OCR failed: #{e.message}")
  end
end
