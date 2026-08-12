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
  end
end
