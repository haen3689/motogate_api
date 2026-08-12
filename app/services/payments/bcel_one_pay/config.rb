module Payments
  module BcelOnePay
    # Test merchant data + endpoints come from BCEL's "OnePay Integration
    # Guide" / "OnePay Void and Refund API" docs. Defaults below are BCEL's
    # published TEST merchant — override every BCEL_* var in production.
    module Config
      extend self

      def mcid
        ENV.fetch("BCEL_MCID", "mch5c2f0404102fb")
      end

      def mcc
        ENV.fetch("BCEL_MCC", "5732")
      end

      def shopcode
        ENV.fetch("BCEL_SHOPCODE", "12345678")
      end

      # LAK — the only currency BCEL OnePay supports.
      def ccy
        ENV.fetch("BCEL_CCY", "418")
      end

      def country
        ENV.fetch("BCEL_COUNTRY", "LA")
      end

      def province
        ENV.fetch("BCEL_PROVINCE", "VTE")
      end

      # PubNub subscribe key baked into BCEL's own onepay.js SDK — shared by
      # all OnePay merchants, not merchant-specific.
      def pubnub_subscribe_key
        ENV.fetch("BCEL_PUBNUB_SUBSCRIBE_KEY", "sub-c-91489692-fa26-11e9-be22-ea7c5aada356")
      end

      def void_url
        ENV.fetch("BCEL_VOID_URL", "https://bcel.la:8083/onepay/void.php")
      end

      def refund_url
        ENV.fetch("BCEL_REFUND_URL", "https://bcel.la:8083/onepay/refund.php")
      end

      # Our own RSA private key (PEM) used to sign void/refund requests. The
      # matching PUBLIC key must be sent to BCEL (phayudon@bcel.com.la) per
      # the Void/Refund API doc before those endpoints will accept calls.
      def private_key_pem
        ENV["BCEL_PRIVATE_KEY_PEM"]
      end

      def listener_enabled?
        ENV.fetch("BCEL_PUBNUB_LISTENER", "true") == "true"
      end

      def merchant_channel
        "mcid-#{mcid}-#{shopcode}"
      end
    end
  end
end
