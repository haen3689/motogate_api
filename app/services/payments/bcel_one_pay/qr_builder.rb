module Payments
  module BcelOnePay
    # Ruby port of the TLV/EMV-QR builder in BCEL's onepay.js (getCode()).
    # Built server-side (not shipped to the app) so the amount and merchant
    # id stay authoritative on our server instead of trusting the client.
    class QrBuilder
      def initialize(transaction_id:, invoice_id:, terminal_id:, amount:, description:, expire_minutes: 15,
                      mcc: nil, ccy: nil, country: nil, province: nil)
        @transaction_id = transaction_id.to_s
        @invoice_id = invoice_id.to_s
        @terminal_id = terminal_id.to_s
        @amount = format_amount(amount)
        @description = description.to_s[0, 100]
        @expire_minutes = expire_minutes
        @mcc = (mcc || Config.mcc).to_s
        @ccy = (ccy || Config.ccy).to_s
        @country = country || Config.country
        @province = province || Config.province
      end

      # Returns the raw QR string (render as an image client-side, or wrap
      # as "onepay://qr/<string>" for the one-click Applink deeplink).
      def build
        field33 = [%w[00 BCEL], %w[01 ONEPAY], ["02", Config.mcid]]
        field33 << ["03", expired_time] if @expire_minutes
        field33 << %w[05 CLOSEWHENDONE]

        raw = build_tlv([
          %w[00 01],
          %w[01 11],
          ["33", build_tlv(field33)],
          ["52", @mcc],
          ["53", @ccy],
          ["54", @amount],
          ["58", @country],
          ["60", @province],
          ["62", build_tlv([
            ["01", @invoice_id],
            ["05", @transaction_id],
            ["07", @terminal_id],
            ["08", @description]
          ])]
        ])

        raw + build_tlv([["63", crc16(raw + "6304")]])
      end

      private

      def format_amount(amount)
        amt = amount.to_d
        amt == amt.to_i ? amt.to_i.to_s : amt.to_s
      end

      def expired_time
        (Time.now.in_time_zone("Asia/Bangkok") + @expire_minutes.to_i.minutes).strftime("%Y%m%d%H%M%S")
      end

      def build_tlv(pairs)
        pairs.each_with_object(+"") do |(key, val), out|
          val = val.to_s
          next if val.empty?

          out << pad2(key) << pad2(val.length) << val
        end
      end

      # Mirrors onepay.js's pad2(): "0" + value, keep the last 2 chars.
      def pad2(val)
        "0#{val}"[-2..]
      end

      # CRC-16/CCITT-FALSE (poly 0x1021, init 0xFFFF, no reflect) — the
      # table-driven crc16() in onepay.js is the standard EMVCo QR checksum.
      def crc16(str)
        crc = 0xFFFF
        str.each_byte do |byte|
          crc ^= (byte << 8)
          8.times do
            crc = (crc & 0x8000).zero? ? (crc << 1) & 0xFFFF : ((crc << 1) ^ 0x1021) & 0xFFFF
          end
        end
        crc.to_s(16).upcase.rjust(4, "0")
      end
    end
  end
end
