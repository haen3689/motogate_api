class Insurance < ApplicationRecord
  include PayableByPayment

  belongs_to :vehicle
  belongs_to :insurance_company, optional: true
  has_one_attached :document_image

  STATUSES = %w[pending active expired cancelled].freeze
  DEFAULT_DURATION_MONTHS = 12
  validates :company, :package, :amount, :status, presence: true
  validates :status, inclusion: { in: STATUSES }

  before_validation :set_insurance_company, if: -> { insurance_company_id.blank? && company.present? }

  def self.ransackable_attributes(auth_object = nil)
    %w[id amount company package status start_date end_date vehicle_id insurance_company_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vehicle insurance_company]
  end

  def payment_owner
    vehicle.user
  end

  # Called by Payment#mark_paid! once BCEL confirms the payment via callback.
  # The policy period starts from the moment payment actually clears, not
  # from when the (possibly abandoned) QR was first shown.
  def mark_paid_from_payment!(payment)
    duration = insurance_company&.insurance_packages&.find_by(name: package)&.duration_months || DEFAULT_DURATION_MONTHS
    start = Date.current
    update!(status: "active", start_date: start, end_date: start >> duration)
    vehicle.user.transactions.create!(
      transaction_type: "insurance",
      amount: payment.amount,
      status: "success",
      reference: vehicle.plate_number,
      description: "ປະກັນໄພ #{package} - #{vehicle.plate_number}"
    )
  rescue StandardError => e
    Rails.logger.error("[Insurance] Failed to finalize payment #{payment.uuid}: #{e.message}")
  end

  private

  def set_insurance_company
    self.insurance_company = InsuranceCompany.find_by(name: company)
  end
end
