class Advertisement < ApplicationRecord
  UPLOAD_DIR = Rails.root.join('public', 'uploads', 'advertisements')

  PLACEMENTS = %w[banner popup sidebar].freeze

  attr_accessor :image_file

  validates :title, presence: true
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :placement, inclusion: { in: PLACEMENTS }

  before_save :attach_image_file, if: -> { image_file.present? }

  scope :active,  -> { where(active: true) }
  scope :ordered, -> { order(:position) }
  # "Running" for API purposes — enabled AND inside its campaign window (or
  # no window set at all, so ads without dates just run indefinitely).
  scope :running, -> {
    active.where("start_date IS NULL OR start_date <= ?", Date.current)
          .where("end_date IS NULL OR end_date >= ?", Date.current)
  }

  # Campaign lifecycle for the admin UI — distinct from the `active` toggle,
  # which is just an admin on/off switch independent of scheduling.
  def campaign_status
    return "inactive" unless active
    return "pending" if start_date.present? && start_date > Date.current
    return "expired" if end_date.present? && end_date < Date.current
    "running"
  end

  def ctr
    return 0.0 if view_count.zero?
    (click_count.to_f / view_count * 100).round(2)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id title subtitle image link_url position active placement start_date end_date click_count view_count created_at updated_at]
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
    self.image = "/uploads/advertisements/#{filename}"
  end
end
