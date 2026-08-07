class Inspection < ApplicationRecord
  belongs_to :vehicle
  belongs_to :inspection_center, optional: true

  STATUSES = %w[pending confirmed completed cancelled].freeze
  STICKER_UPLOAD_DIR = Rails.root.join('public', 'uploads', 'inspection_stickers')

  attr_accessor :sticker_file

  validates :center_name, :appointment_at, :status, presence: true
  validates :status, inclusion: { in: STATUSES }

  before_save :attach_sticker_file, if: -> { sticker_file.present? }

  def self.ransackable_attributes(auth_object = nil)
    %w[id center_name service_name amount appointment_at status sticker notes created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vehicle inspection_center]
  end

  private

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
