class User < ApplicationRecord
  has_many :vehicles, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :chat_messages, dependent: :destroy
  has_one :support_case, dependent: :destroy

  has_one_attached :id_card_image
  has_one_attached :license_image
  has_one_attached :profile_image

  validates :phone_number, presence: true, uniqueness: true

  def generate_otp
    self.otp = rand(100000..999999).to_s
    self.otp_expired_at = 5.minutes.from_now
    self.verified = false
    save!
    otp
  end

  def verify_otp!(code)
    raise "OTP expired" if otp_expired_at < Time.current
    raise "OTP invalid" unless otp == code
    update!(verified: true, otp: nil, otp_expired_at: nil)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id name first_name last_name phone_number gender date_of_birth
       province district village id_type id_number id_expiry_date
       license_number license_type license_expiry_date verified created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vehicles transactions notifications chat_messages]
  end
end
