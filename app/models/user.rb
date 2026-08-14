class User < ApplicationRecord
  has_many :vehicles, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :chat_messages, dependent: :destroy
  has_one :support_case, dependent: :destroy
  has_many :vehicle_shares, dependent: :destroy
  has_many :shared_vehicles, through: :vehicle_shares, source: :vehicle

  has_one_attached :id_card_image
  has_one_attached :license_image
  has_one_attached :profile_image

  validates :phone_number, presence: true, uniqueness: true

  # A wrong guess used to cost an attacker nothing — the code stayed valid for
  # its full five minutes, no counter moved, and nothing rate limits the
  # endpoint — so all 10^6 six-digit codes were reachable inside the window.
  MAX_OTP_ATTEMPTS = 5

  def generate_otp
    # SecureRandom, not rand: Kernel#rand is a Mersenne Twister seeded per
    # process, which is predictable from observed outputs and must not decide
    # an authentication secret.
    self.otp = SecureRandom.random_number(900_000).+(100_000).to_s
    self.otp_expired_at = 5.minutes.from_now
    self.otp_attempts = 0
    self.verified = false
    save!
    otp
  end

  def verify_otp!(code)
    # otp_expired_at is nil both before any OTP is requested and after a
    # successful verify, where `nil < Time.current` raised NoMethodError and
    # surfaced to the client as a 422 containing the raw Ruby error.
    raise "No OTP requested" if otp.blank? || otp_expired_at.blank?
    raise "OTP expired" if otp_expired_at < Time.current

    if otp_attempts.to_i >= MAX_OTP_ATTEMPTS
      # Burn the code rather than just refusing, so an attacker can't keep
      # guessing simply by waiting out a counter.
      update!(otp: nil, otp_expired_at: nil, otp_attempts: 0)
      raise "Too many incorrect attempts. Request a new OTP."
    end

    unless ActiveSupport::SecurityUtils.secure_compare(otp.to_s, code.to_s)
      increment!(:otp_attempts)
      raise "OTP invalid"
    end

    update!(verified: true, otp: nil, otp_expired_at: nil, otp_attempts: 0)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id name first_name last_name phone_number gender date_of_birth
       province district village id_type id_number id_expiry_date
       license_name license_number license_type license_expiry_date verified created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vehicles transactions notifications chat_messages]
  end
end
