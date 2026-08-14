# Boots the persistent PubNub subscription that receives BCEL OnePay
# payment-success callbacks (see app/services/payments/bcel_one_pay).
#
# Guarded to only run inside an actual running server process — not during
# `rails console`, `rails db:migrate`, asset precompile, tests, etc. — since
# those shouldn't hold an open PubNub connection. Disable entirely (e.g. for
# a second app instance you don't want double-receiving callbacks) by
# setting BCEL_PUBNUB_LISTENER=false.
Rails.application.config.after_initialize do
  if defined?(Rails::Server) || ENV["RUN_BCEL_LISTENER"] == "true"
    Payments::BcelOnePay::CallbackListener.start!

    # Falling back to BCEL's published TEST merchant is the correct setup
    # during beta, but nothing in the app says so out loud — RAILS_ENV is
    # already "production" on the beta deploy, so there is no signal at all
    # distinguishing "beta on the sandbox merchant" from "live and quietly
    # sending customers' money to BCEL's test account". This makes it
    # impossible to miss in the logs.
    #
    # Set BCEL_REQUIRE_PRODUCTION_MERCHANT=true when going live: boot then
    # fails fast instead of warning, so a missing BCEL_MCID can never reach
    # real customers.
    if Rails.env.production? && ENV["BCEL_MCID"].blank?
      message = "[BcelOnePay] BCEL_MCID is not set — using BCEL's published " \
                "TEST merchant (#{Payments::BcelOnePay::Config.mcid}) on channel " \
                "#{Payments::BcelOnePay::Config.merchant_channel}. Every QR this " \
                "app generates carries that test merchant id, and the channel is " \
                "shared with other OnePay integrators. Fine for beta; set BCEL_MCID, " \
                "BCEL_SHOPCODE and the other BCEL_* vars before taking real payments."

      if ENV["BCEL_REQUIRE_PRODUCTION_MERCHANT"] == "true"
        raise message
      else
        Rails.logger.warn("=" * 80)
        Rails.logger.warn(message)
        Rails.logger.warn("=" * 80)
      end
    end
  end
end
