class InsuranceCompany < ApplicationRecord
  has_many :insurance_packages, dependent: :destroy
  accepts_nested_attributes_for :insurance_packages, allow_destroy: true,
    reject_if: proc { |attrs| attrs['name'].blank? }

  STATUSES = %w[active inactive].freeze
  LOGO_UPLOAD_DIR = Rails.root.join('public', 'uploads', 'insurance_logos')

  attr_accessor :logo_file

  before_save :attach_logo_file, if: -> { logo_file.present? }

  scope :active, -> { where(status: 'active') }

  def self.ransackable_attributes(auth_object = nil)
    %w[id name phone email status created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[insurance_packages]
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
    self.logo = "/uploads/insurance_logos/#{filename}"
  end
end
