require "openssl"
require "base64"

module Payments
  module BcelOnePay
    # Signs void/refund requests with our RSA private key (SHA256withRSA),
    # per the BCEL Void/Refund API doc. The matching public key must be
    # handed to BCEL out-of-band before they'll accept our signatures.
    class Signer
      class MissingKeyError < StandardError; end

      def self.sign(data)
        pem = Config.private_key_pem
        raise MissingKeyError, "BCEL_PRIVATE_KEY_PEM is not configured" if pem.blank?

        key = OpenSSL::PKey::RSA.new(pem)
        Base64.strict_encode64(key.sign(OpenSSL::Digest.new("SHA256"), data))
      end
    end
  end
end
