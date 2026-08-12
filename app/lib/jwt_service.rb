class JwtService
  SECRET = Rails.application.secret_key_base

  # expiry: nil means the token never expires — used for the main login
  # session, which should stay valid until the user explicitly logs out.
  # Short-lived tokens (e.g. the QR verify_token) pass an explicit expiry.
  def self.encode(user_id, expiry: nil, extra: {})
    payload = { user_id: user_id }.merge(extra)
    payload[:exp] = expiry.from_now.to_i if expiry
    JWT.encode(payload, SECRET, "HS256")
  end

  def self.decode(token)
    body = JWT.decode(token, SECRET, true, algorithm: "HS256").first
    HashWithIndifferentAccess.new(body)
  rescue JWT::ExpiredSignature
    raise "Token expired"
  rescue JWT::DecodeError
    raise "Invalid token"
  end
end
