class SendOtpSmsJob < ApplicationJob
  queue_as :default

  def perform(phone_number:, otp:)
    TelbizSmsService.send_otp(phone_number: phone_number, otp: otp)
  end
end
