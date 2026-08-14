class Inspection < ApplicationRecord
  include PayableByPayment

  belongs_to :vehicle
  belongs_to :inspection_center, optional: true

  STATUSES = %w[pending confirmed completed cancelled].freeze
  STICKER_UPLOAD_DIR = Rails.root.join('public', 'uploads', 'inspection_stickers')

  attr_accessor :sticker_file

  validates :center_name, :appointment_at, :status, presence: true
  validates :status, inclusion: { in: STATUSES }

  before_save :attach_sticker_file, if: -> { sticker_file.present? }

  def self.ransackable_attributes(auth_object = nil)
    %w[id center_name service_name amount appointment_at status sticker sticker_number notes created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vehicle inspection_center]
  end

  def payment_owner
    vehicle.user
  end

  # Called by Payment#mark_paid! once BCEL confirms the payment via
  # callback — the booking only becomes "confirmed" (and the center
  # notified) once payment has actually cleared.
  def mark_paid_from_payment!(payment)
    update!(status: "confirmed")
    vehicle.user.transactions.create!(
      transaction_type: "inspection",
      amount: payment.amount,
      status: "success",
      reference: vehicle.plate_number,
      description: "#{service_name} - #{vehicle.plate_number}",
      payment: payment
    )
    notify_center!
    broadcast_new_booking!
  end
  # No blanket rescue — see the note in Insurance#mark_paid_from_payment!.
  # notify_center! and broadcast_new_booking! already rescue individually, so
  # this only ever swallowed the database writes above, which are exactly the
  # part that must not fail silently.

  private

  # Notify the inspection center's phone that a new (paid) booking came in.
  # Best-effort — must never break payment finalization if SMS is down.
  def notify_center!
    return if inspection_center.blank? || inspection_center.phone.blank?

    message = "ມີການຈອງກວດສະພາບລົດໃໝ່ ທະບຽນ #{vehicle.plate_number} " \
              "ບໍລິການ #{service_name} ວັນທີ #{appointment_at.strftime('%d/%m/%Y %H:%M')}"
    TelbizSmsService.send_message(phone_number: inspection_center.phone, message: message)
  rescue StandardError => e
    Rails.logger.error("[Inspection] Failed to notify center #{inspection_center&.id}: #{e.message}")
  end

  # Pushes the new booking to any admin browser currently subscribed via
  # AdminInspectionsChannel, so the backend list updates live. Best-effort,
  # same as notify_center!.
  def broadcast_new_booking!
    ActionCable.server.broadcast("admin_inspections", {
      inspection: as_json.merge(plate_number: vehicle.plate_number)
    })
  rescue StandardError => e
    Rails.logger.error("[Inspection] Failed to broadcast new booking #{id}: #{e.message}")
  end

  def attach_sticker_file
    unless sticker_file.content_type.to_s.start_with?('image/')
      errors.add(:sticker_file, 'ຕ້ອງເປັນຮູບພາບເທົ່ານັ້ນ')
      throw :abort
    end

    FileUtils.mkdir_p(STICKER_UPLOAD_DIR)
    filename = "#{SecureRandom.hex(10)}#{File.extname(sticker_file.original_filename)}"
    File.open(STICKER_UPLOAD_DIR.join(filename), 'wb') { |f| f.write(sticker_file.read) }
    self.sticker = "/uploads/inspection_stickers/#{filename}"
  end
end
