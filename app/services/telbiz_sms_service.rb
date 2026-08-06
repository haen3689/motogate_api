require "net/http"
require "uri"
require "json"

class TelbizSmsService
  BASE_URL  = "https://api.telbiz.la/api/v1"
  CLIENT_ID = ENV.fetch("TELBIZ_CLIENT_ID", "")
  SECRET    = ENV.fetch("TELBIZ_SECRET",    "")

  def self.send_otp(phone_number:, otp:)
    new(phone_number:, otp:).send!
  end

  def initialize(phone_number:, otp:)
    @phone_number = normalize_phone(phone_number)
    @otp          = otp
  end

  def send!
    token = connect_token
    send_sms(token)
  end

  private

  # Step 1: Get access token
  def connect_token
    body = {
      clientID:  CLIENT_ID,
      secret:    SECRET,
      grantType: "client_credentials",
      scope:     "Telbiz_API_SCOPE profile openid"
    }
    res = post("#{BASE_URL}/connect/token", body, {})
    raise "Telbiz auth failed: #{res.body}" unless res.code.to_i == 200

    JSON.parse(res.body)["accessToken"] ||
      raise("Telbiz: no accessToken in response")
  end

  # Step 2: Send SMS with Bearer token
  def send_sms(access_token)
    body = {
      title:   "OTP",
      phone:   @phone_number,
      message: "ລະຫັດ MotoGate OTP ຂອງທ່ານແມ່ນ: #{@otp} "
    }
    headers = { "Authorization" => "Bearer #{access_token}" }
    res = post("#{BASE_URL}/smsservice/newtransaction", body, headers)

    unless res.code.to_i == 200
      Rails.logger.error("[Telbiz] SMS failed: #{res.code} #{res.body}")
      raise "SMS sending failed"
    end

    Rails.logger.info("[Telbiz] SMS sent to #{@phone_number}")
    true
  end

  def post(url, body, extra_headers)
    uri  = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(uri.path,
      "accept"       => "text/plain",
      "Content-Type" => "application/json"
    )
    extra_headers.each { |k, v| req[k] = v }
    req.body = body.to_json

    http.request(req)
  end

  # +85620XXXXXXX or 020XXXXXXX → 20XXXXXXX
  def normalize_phone(number)
    number.sub(/^\+856/, "").sub(/^0/, "")
  end
end
