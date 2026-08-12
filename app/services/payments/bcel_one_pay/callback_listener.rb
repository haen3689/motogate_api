require "json"

module Payments
  module BcelOnePay
    # Subscribes at "Merchant Level" (channel "mcid-<mcid>-<shopcode>") to
    # receive BCEL's payment-success callback via PubNub, per the OnePay
    # Integration Guide. There is no polling/webhook alternative in BCEL's
    # API — this persistent subscription is the only way our server learns
    # a payment succeeded, so it must be running whenever the app is live.
    #
    # The `pubnub` gem's #subscribe is non-blocking (it manages its own
    # background threads), so calling .start once at boot is enough.
    class CallbackListener
      def self.start!
        return unless Config.listener_enabled?

        new.start
      end

      def start
        pubnub.add_listener(name: "bcel_one_pay", callback: callback)
        pubnub.subscribe(channel: Config.merchant_channel)
        Rails.logger.info("[BcelOnePay] Listening on PubNub channel #{Config.merchant_channel}")
      rescue StandardError => e
        Rails.logger.error("[BcelOnePay] Failed to start PubNub listener: #{e.message}")
      end

      private

      def pubnub
        @pubnub ||= Pubnub.new(subscribe_key: Config.pubnub_subscribe_key, uuid: "BCELBANK-motogate-api")
      end

      def callback
        Pubnub::SubscribeCallback.new(
          message: ->(envelope) { handle_message(envelope) },
          presence: ->(_envelope) {},
          status: ->(envelope) { handle_status(envelope) }
        )
      end

      def handle_status(envelope)
        return unless envelope.status[:error]

        Rails.logger.error("[BcelOnePay] PubNub status error: #{envelope.status}")
      end

      def handle_message(envelope)
        message = envelope.result[:data][:message]
        payload = message.is_a?(String) ? JSON.parse(message) : message
        uuid = payload["uuid"] || payload["iid"]
        return if uuid.blank?

        payment = Payment.find_by(uuid: uuid)
        unless payment
          Rails.logger.warn("[BcelOnePay] Callback for unknown payment uuid=#{uuid}")
          return
        end

        payment.mark_paid!(payload)
        Rails.logger.info("[BcelOnePay] Payment #{uuid} marked paid via callback")
      rescue StandardError => e
        Rails.logger.error("[BcelOnePay] Failed to handle callback: #{e.message}")
      end
    end
  end
end
