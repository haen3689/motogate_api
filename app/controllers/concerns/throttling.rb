# Coarse per-caller rate limiting for the handful of unauthenticated endpoints
# that cost real money or send real SMS.
#
# There is no rack-attack (or any other throttling middleware) in the stack, so
# request_otp could be driven in a loop to bill Telbiz indefinitely and
# ocr/scan to bill Google Vision — neither needs an account to reach.
#
# Deliberately simple: a fixed window counted in Rails.cache, which is
# solid_cache and therefore shared across processes. The read-modify-write is
# not atomic, so a burst of simultaneous requests can slip a few over the
# limit; that is fine for the purpose here, which is stopping sustained abuse
# rather than enforcing an exact quota. If precise limits are ever needed,
# reach for rack-attack instead of tightening this.
module Throttling
  extend ActiveSupport::Concern

  class TooManyRequests < StandardError; end

  included do
    rescue_from TooManyRequests do |e|
      render json: { success: false, error: e.message }, status: :too_many_requests
    end
  end

  private

  def throttle!(bucket:, limit:, period:, by: nil, message: "Too many requests. Please try again later.")
    identifier = by.presence || request.remote_ip
    window = Time.current.to_i / period.to_i
    key = "throttle:#{bucket}:#{identifier}:#{window}"

    count = Rails.cache.read(key).to_i + 1
    Rails.cache.write(key, count, expires_in: period * 2)

    return if count <= limit

    Rails.logger.warn("[Throttle] #{bucket} limit hit by #{identifier} (#{count}/#{limit})")
    raise TooManyRequests, message
  rescue TooManyRequests
    raise
  rescue StandardError => e
    # A cache outage must not take down the endpoint it is protecting.
    Rails.logger.error("[Throttle] #{bucket} check failed, allowing request: #{e.message}")
  end
end
