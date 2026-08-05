class JwtService
  SECRET = Rails.application.secret_key_base
  EXPIRY = 30.days

  def self.encode(user_id)
    payload = { user_id: user_id, exp: EXPIRY.from_now.to_i }
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
