class Announcement < ApplicationRecord
  UPLOAD_DIR = Rails.root.join('public', 'uploads', 'announcements')

  CATEGORIES = %w[maintenance promotion feature event].freeze

  attr_accessor :image_file

  validates :title, presence: true
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, inclusion: { in: CATEGORIES }

  before_save :attach_image_file, if: -> { image_file.present? }

  scope :active,  -> { where(active: true) }
  scope :ordered, -> { order(position: :desc, created_at: :desc) }

  def self.ransackable_attributes(auth_object = nil)
    %w[id title body image position active category author view_count created_at updated_at]
  end

  private

  def attach_image_file
    unless image_file.content_type.to_s.start_with?('image/')
      errors.add(:image_file, 'ຕ້ອງເປັນຮູບພາບເທົ່ານັ້ນ')
      throw :abort
    end

    FileUtils.mkdir_p(UPLOAD_DIR)
    filename = "#{SecureRandom.hex(10)}#{File.extname(image_file.original_filename)}"
    File.open(UPLOAD_DIR.join(filename), 'wb') { |f| f.write(image_file.read) }
    self.image = "/uploads/announcements/#{filename}"
  end
end
