require 'net/http'
require 'json'
require 'base64'

class Api::V1::OcrController < ApiController
  # OCR is called before user is fully authenticated (testing mode / onboarding)
  skip_before_action :authenticate!

  def scan
    image = params[:image]
    return render_error('No image provided') unless image.present?

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
