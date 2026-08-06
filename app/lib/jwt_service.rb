class JwtService
  SECRET = Rails.application.secret_key_base
  EXPIRY = 30.days

  def self.encode(user_id, expiry: EXPIRY, extra: {})
    payload = { user_id: user_id, exp: expiry.from_now.to_i }.merge(extra)
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
