require "net/http"
require "uri"
require "json"

class TelbizSmsService
  BASE_URL  = "https://api.telbiz.la/api/v1"
  CLIENT_ID = ENV.fetch("TELBIZ_CLIENT_ID", "")
  # ✅ แก้ไขให้ตรงกับ KEY บน Render Dashboard (TELBIZ_SECRET_KEY)
  SECRET    = ENV.fetch("TELBIZ_SECRET_KEY", ENV.fetch("TELBIZ_SECRET", ""))

  def self.send_otp(phone_number:, otp:)
    new(phone_number:, title: "OTP", message: "ລະຫັດ AutoPass OTP ຂອງທ່ານແມ່ນ: #{otp} ").send!
  end

  # Telbiz's "title" is a fixed enum, not freeform text — only
  # Telbiz | Info | News | OTP | Promotion are accepted (anything else
  # is rejected with UNSUPPORTED_HEADER). Non-OTP transactional
  # messages (e.g. booking notifications) should use "Info".
  def self.send_message(phone_number:, message:, title: "Info")
    new(phone_number:, title:, message:).send!
  end

  def initialize(phone_number:, title:, message:)
    @phone_number = normalize_phone(phone_number)
    @title        = title
    @message      = message
  end

  def send!
    token = connect_token
    send_sms(token)
  rescue StandardError => e
    Rails.logger.error("[Telbiz Execution Error] #{e.message}")
    false
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
    
    unless res.code.to_i == 200
      Rails.logger.error("[Telbiz Auth Failed] Status: #{res.code}, Body: #{res.body}")
      raise "Telbiz auth failed: #{res.body}"
    end

    JSON.parse(res.body)["accessToken"] ||
      raise("Telbiz: no accessToken in response")
  end

  # Step 2: Send SMS with Bearer token
  def send_sms(access_token)
    body = {
      title:   @title,
      phone:   @phone_number,
      message: @message
    }
    headers = { "Authorization" => "Bearer #{access_token}" }
    res = post("#{BASE_URL}/smsservice/newtransaction", body, headers)

    unless res.code.to_i == 200
      Rails.logger.error("[Telbiz] SMS failed: #{res.code} #{res.body}")
      raise "SMS sending failed: #{res.body}"
    end

    Rails.logger.info("[Telbiz] SMS sent successfully to #{@phone_number}")
    true
  end

  def post(url, body, extra_headers)
    uri  = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    # ✅ ป้องกัน HTTP Request ค้างเกินไปจนเกิด Connection Reset บน Render Free Tier
    http.open_timeout = 5
    http.read_timeout = 8

    req = Net::HTTP::Post.new(
      uri.path,
      "accept"       => "text/plain",
      "Content-Type" => "application/json"
    )
    extra_headers.each { |k, v| req[k] = v }
    req.body = body.to_json

    http.request(req)
  end

  # +85620XXXXXXX or 020XXXXXXX → 20XXXXXXX
  def normalize_phone(number)
    number.to_s.sub(/^\+856/, "").sub(/^0/, "")
  end
end