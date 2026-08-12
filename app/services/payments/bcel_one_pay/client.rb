require "net/http"
require "uri"
require "json"

module Payments
  module BcelOnePay
    # Server-to-server Void/Refund calls per "BCEL E-Commerce OnePay
    # Void and Refund API 1.0.2".
    class Client
      Result = Struct.new(:success?, :code, :message, :raw)

      # Only valid same-day, before 21:00 Bangkok time, and only once per
      # transaction — BCEL rejects anything else; we don't duplicate those
      # rules here; the failure reason comes back in the response.
      def self.void(uuid:)
        data = "#{Config.mcid}#{uuid}"
        post(Config.void_url, mcid: Config.mcid, uuid: uuid, signature: Signer.sign(data))
      end

      # Full or partial, may be called multiple times up to the original
      # amount, within 30 days of the transaction.
      def self.refund(uuid:, refund_id:, refund_amount:)
        data = "#{Config.mcid}#{uuid}#{refund_id}"
        post(
          Config.refund_url,
          mcid: Config.mcid,
          uuid: uuid,
          refundid: refund_id,
          refundamount: refund_amount,
          signature: Signer.sign(data)
        )
      end

      def self.post(url, body)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.open_timeout = 8
        http.read_timeout = 15

        req = Net::HTTP::Post.new(uri.request_uri, "Content-Type" => "application/x-www-form-urlencoded")
        req.body = URI.encode_www_form(body)
        res = http.request(req)

        parsed = JSON.parse(res.body)
        result_code = parsed["result"]
        Result.new(result_code == 0, result_code, parsed["message"], parsed)
      rescue JSON::ParserError, StandardError => e
        Result.new(false, nil, "BCEL request failed: #{e.message}", nil)
      end
      private_class_method :post
    end
  end
end
