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
    # background threads), so calling .start once at boot is enough. Even
    # so, #start! itself runs in its own Thread — it's called from
    # Rails.application.config.after_initialize (see
    # config/initializers/bcel_one_pay.rb), and if PubNub's own client
    # setup (DNS, initial connection) ever stalls or is slow to fail, that
    # would block the rest of Rails' boot sequence and delay the app from
    # accepting connections at all — turning a flaky third-party dependency
    # into a full outage instead of "callbacks are late/missing".
    class CallbackListener
      # How often to replay recent PubNub messages as a safety net beyond
      # the live subscription — catches a callback that arrived while the
      # subscription was silently dead (e.g. a dropped connection the
      # `pubnub` gem didn't recover from) or one `handle_message` failed
      # to process due to a transient error (DB hiccup, etc). Reconciling
      # is idempotent (see #reconcile_recent!), so re-running it on a
      # schedule is safe.
      RECONCILE_INTERVAL = 5.minutes

      def self.start!
        return unless Config.listener_enabled?

        Thread.new do
          begin
            listener = new
            listener.start
            loop do
              sleep RECONCILE_INTERVAL
              listener.reconcile_recent!
            end
          rescue StandardError => e
            Rails.logger.error("[BcelOnePay] Listener thread crashed: #{e.message}")
          end
        end
      end

      def start
        pubnub.add_listener(name: "bcel_one_pay", callback: callback)
        pubnub.subscribe(channel: Config.merchant_channel)
        Rails.logger.info("[BcelOnePay] Listening on PubNub channel #{Config.merchant_channel}")

        # The live subscription above only sees messages published *after*
        # this process started listening — if the process was down (deploy,
        # crash, cold start) at the exact moment BCEL published a
        # success callback, that message is otherwise lost forever: our
        # `mark_paid!` DB write never happens, the payment stays "pending",
        # and the app's QR screen polls indefinitely with nothing to find.
        # PubNub retains recent messages on this channel (mark_paid!'s own
        # idempotency comment already relies on that retention for
        # reconnect replay), so on every boot we also replay the most
        # recent messages through the same idempotent handler to close
        # that gap.
        reconcile_recent!
      rescue StandardError => e
        Rails.logger.error("[BcelOnePay] Failed to start PubNub listener: #{e.message}")
      end

      # Re-processes the most recent stored messages on the merchant
      # channel so a payment whose callback arrived while no process was
      # listening still gets marked paid. Safe to run any time: uuid
      # lookup skips anything unknown and Payment#mark_paid! is a no-op
      # for an already-paid payment, so replaying old/duplicate messages
      # cannot double-apply a payment or affect ones that are still
      # genuinely pending.
      def reconcile_recent!
        pubnub.fetch_messages(channels: [Config.merchant_channel], max: 100) do |envelope|
          if envelope.status[:error]
            Rails.logger.error("[BcelOnePay] Reconcile fetch failed: #{envelope.status[:error]}")
            next
          end

          entries = envelope.result.dig(:data, :channels, Config.merchant_channel) || []
          entries.each { |entry| process_payload(entry["message"]) }
          Rails.logger.info("[BcelOnePay] Reconcile checked #{entries.size} recent callback message(s)")
        end
      rescue StandardError => e
        Rails.logger.error("[BcelOnePay] Reconcile failed to start: #{e.message}")
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
        process_payload(message)
      rescue StandardError => e
        Rails.logger.error("[BcelOnePay] Failed to handle callback: #{e.message}")
      end

      def process_payload(message)
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
