# Boot-time checks for configuration that is safe today only because of a
# coincidence, and would break quietly the moment the coincidence stops
# holding. Warnings only — none of these should stop the app from starting.
Rails.application.config.after_initialize do
  next unless Rails.env.production?

  warn_lines = []

  # config/cable.yml uses the :async adapter in production. That adapter keeps
  # subscriptions in the memory of a single process, so a broadcast made in one
  # process is invisible to clients connected to another. It works right now
  # purely because WEB_CONCURRENCY is 1. Raise the worker count and realtime
  # silently stops reaching roughly half the users, with no error anywhere.
  cable_adapter = Rails.application.config_for(:cable)[:adapter].to_s
  workers = ENV.fetch("WEB_CONCURRENCY", "1").to_i

  if cable_adapter == "async" && workers > 1
    warn_lines << "ActionCable is on the :async adapter with WEB_CONCURRENCY=#{workers}. " \
                  "Broadcasts do not cross processes, so realtime updates will reach only " \
                  "the clients that happen to be connected to the publishing worker. Use a " \
                  "cross-process adapter (solid_cable or redis) before running more than one worker."
  end

  if ENV["ALLOW_DEBUG"] == "true"
    warn_lines << "ALLOW_DEBUG=true — /api/v1/auth/request_otp_debug returns a plaintext OTP " \
                  "for any phone number, which bypasses authentication completely."
  end

  if ENV["ALLOW_UNVERIFIED_PHONE_LOGIN"] == "true"
    warn_lines << "ALLOW_UNVERIFIED_PHONE_LOGIN=true — /api/v1/auth/login_phone accepts a phone " \
                  "number with no OTP and returns a session token. Intended only as a temporary " \
                  "rollback lever while an updated app build ships."
  end

  next if warn_lines.empty?

  Rails.logger.warn("=" * 80)
  warn_lines.each { |line| Rails.logger.warn("[SanityCheck] #{line}") }
  Rails.logger.warn("=" * 80)
end
