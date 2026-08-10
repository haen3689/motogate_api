class ServiceCenter < ApplicationRecord
  LOGO_UPLOAD_DIR = Rails.root.join('public', 'uploads', 'service_center_logos')

  STATUSES      = %w[active inactive].freeze
  SERVICE_TYPES = %w[garage dealer towing].freeze

  attr_accessor :logo_file

  has_many :service_center_contracts, dependent: :destroy
  has_many :partner_applications, dependent: :nullify

  validates :name, presence: true
  validates :service_type, inclusion: { in: SERVICE_TYPES }
  validates :status, inclusion: { in: STATUSES }, allow_blank: true

  before_save :attach_logo_file, if: -> { logo_file.present? }

  scope :active, -> { where(status: 'active') }
  scope :garage, -> { where(service_type: 'garage') }
  scope :towing, -> { where(service_type: 'towing') }
  scope :dealer, -> { where(service_type: 'dealer') }

  # A center shows up in the app if it's enabled AND either has no rental
  # contract on file yet (not onboarded into billing — stays visible by
  # default rather than vanishing) or has at least one contract that's
  # still in its active window. Once every contract on file has lapsed,
  # the listing disappears until renewed.
  def visible_in_app?
    return false unless status == 'active'
    return true if service_center_contracts.empty?
    service_center_contracts.any?(&:visible?)
  end

  # "ປົກກະຕິ" (normal) / "ໃກ້ໝົດອາຍຸ" (expiring within 30 days) / "ໝົດສັນຍາ" (expired) —
  # mirrors the grandfather rule in visible_in_app?: a center with no
  # contract on file yet still reads as "normal" rather than "expired".
  def contract_status
    contracts = service_center_contracts.to_a
    return "normal" if contracts.empty?

    active = contracts.select { |c| c.effective_status == "active" }
    return "expired" if active.empty?

    active.any? { |c| c.end_date.present? && c.end_date <= 30.days.from_now.to_date } ? "expiring" : "normal"
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id name location phone owner_name service_type status specialty rating lat lng created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[service_center_contracts]
  end

  private

  def attach_logo_file
    unless logo_file.content_type.to_s.start_with?('image/')
      errors.add(:logo_file, 'ຕ້ອງເປັນຮູບພາບເທົ່ານັ້ນ')
      throw :abort
    end

    FileUtils.mkdir_p(LOGO_UPLOAD_DIR)
    filename = "#{SecureRandom.hex(10)}#{File.extname(logo_file.original_filename)}"
    File.open(LOGO_UPLOAD_DIR.join(filename), 'wb') { |f| f.write(logo_file.read) }
    self.logo = "/uploads/service_center_logos/#{filename}"
  end
end
