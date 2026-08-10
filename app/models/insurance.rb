class Insurance < ApplicationRecord
  belongs_to :vehicle
  belongs_to :insurance_company, optional: true
  has_one_attached :document_image

  STATUSES = %w[pending active expired cancelled].freeze
  validates :company, :package, :amount, :status, presence: true
  validates :status, inclusion: { in: STATUSES }

  before_validation :set_insurance_company, if: -> { insurance_company_id.blank? && company.present? }

  def self.ransackable_attributes(auth_object = nil)
    %w[id amount company package status start_date end_date vehicle_id insurance_company_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vehicle insurance_company]
  end

  private

  def set_insurance_company
    self.insurance_company = InsuranceCompany.find_by(name: company)
  end
end
