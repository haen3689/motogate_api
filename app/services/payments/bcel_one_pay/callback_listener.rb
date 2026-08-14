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
      RECONCILE_INTERVAL = 15.minutes

      # How many stored messages to pull per reconcile. The merchant channel
      # is shared with every other OnePay merchant, so most of what comes
      # back is other people's traffic — pulling 100 every 5 minutes meant
      # re-parsing ~1,200 foreign payloads an hour for nothing.
      RECONCILE_MAX_MESSAGES = 50

      # Reconcile used to re-process *every* message it fetched on *every*
      # run, forever: the same payloads were JSON-parsed and looked up in the
      # DB again every interval, and each already-paid payment re-logged
      # "marked paid" as if it had just happened. We now remember which
      # PubNub timetokens we've already handled and skip them. The set is
      # capped so it can't grow without bound (the bug this replaced).
      SEEN_LIMIT = 500

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
        pubnub.fetch_messages(channels: [Config.merchant_channel], max: RECONCILE_MAX_MESSAGES) do |envelope|
          # fetch_messages is asynchronous when given a block — this runs on
          # a pubnub-owned thread, so an exception escaping here is invisible
          # to the caller's rescue below and would silently kill reconcile.
          # Keep the whole body guarded.
          begin
            if envelope.status[:error]
              Rails.logger.error("[BcelOnePay] Reconcile fetch failed: #{envelope.status[:error]}")
              next
            end

            entries = envelope.result.dig(:data, :channels, Config.merchant_channel) || []
            handled = 0

            entries.each do |entry|
              next if seen?(entry)

              # Only record the message as handled once processing actually
              # succeeded. Marking it before/regardless would defeat the whole
              # point of reconcile: a callback that failed on a transient error
              # (DB hiccup, pool timeout) would be skipped by every later run
              # and the payment would sit "pending" forever with the customer's
              # money already taken.
              next unless process_payload(entry["message"])

              mark_seen(entry)
              handled += 1
            end

            if handled.positive?
              Rails.logger.info(
                "[BcelOnePay] Reconcile checked #{entries.size} message(s), handled #{handled} new"
              )
            end
          rescue StandardError => e
            Rails.logger.error("[BcelOnePay] Reconcile callback failed: #{e.message}")
          end
        end
      rescue StandardError => e
        Rails.logger.error("[BcelOnePay] Reconcile failed to start: #{e.message}")
      end

      private

      # Whether this message was already processed successfully. Keyed on
      # PubNub's per-message timetoken, which is unique and monotonic on the
      # channel. Read/written from pubnub's own thread, hence the mutex.
      #
      # Deliberately a pure predicate — recording is a separate step
      # (#mark_seen) so that a message is only ever skipped after it has been
      # handled, never merely because it was looked at.
      def seen?(entry)
        token = timetoken_for(entry)
        return false if token.nil?

        seen_mutex.synchronize { seen_timetokens.key?(token) }
      end

      def mark_seen(entry)
        token = timetoken_for(entry)
        return if token.nil?

        seen_mutex.synchronize do
          seen_timetokens[token] = true
          # Hashes preserve insertion order, so the first key is the oldest.
          seen_timetokens.delete(seen_timetokens.first[0]) while seen_timetokens.size > SEEN_LIMIT
        end
      end

      def timetoken_for(entry)
        entry["timetoken"] || entry[:timetoken]
      end

      def seen_timetokens
        @seen_timetokens ||= {}
      end

      def seen_mutex
        @seen_mutex ||= Mutex.new
      end

      def pubnub
        # The pubnub gem defaults to Logger.new("pubnub.log") — a relative
        # path in the process's working directory — when no :logger is
        # given. On Render that directory isn't writable, so Pubnub.new
        # itself raised Errno::EACCES on every call, meaning the listener
        # (and the reconcile_recent! safety net) never actually connected
        # at all. Pointing it at IO::NULL avoids touching the filesystem;
        # our own [BcelOnePay] logging above already covers what matters.
        @pubnub ||= Pubnub.new(
          subscribe_key: Config.pubnub_subscribe_key,
          uuid: "BCELBANK-motogate-api",
          logger: Logger.new(IO::NULL)
        )
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

      # Returns true when the message reached a final state (applied, or
      # definitively not ours), false when it failed for a reason that might
      # succeed on a later attempt. Reconcile uses this to decide whether the
      # message may be marked as handled.
      def process_payload(message)
        payload = message.is_a?(String) ? JSON.parse(message) : message
        uuid = payload["uuid"] || payload["iid"]
        return true if uuid.blank?

        payment = Payment.find_by(uuid: uuid)
        unless payment
          # The merchant channel carries every OnePay merchant's traffic, so
          # a uuid we don't recognise is the normal case, not a fault. Logged
          # at debug so it stops flooding production logs.
          Rails.logger.debug("[BcelOnePay] Callback for unknown payment uuid=#{uuid}")
          # Not ours and never will be — final, so it won't be re-examined.
          return true
        end

        # Only announce a real state change — mark_paid! is a no-op for an
        # already-paid payment, and logging unconditionally made replayed
        # messages look like fresh payments in the log every interval.
        if payment.mark_paid!(payload)
          Rails.logger.info("[BcelOnePay] Payment #{uuid} marked paid via callback")
        end
        true
      rescue StandardError => e
        Rails.logger.error("[BcelOnePay] Failed to handle callback: #{e.message}")
        false
      end
    end
  end
end
