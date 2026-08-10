class ServiceCenterContract < ApplicationRecord
  belongs_to :service_center
  has_many :service_center_payments, dependent: :destroy

  BILLING_CYCLES = %w[monthly yearly].freeze
  STATUSES = %w[active pending expired terminated].freeze

  validates :contract_number, presence: true, uniqueness: true
  validates :rent_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :billing_cycle, inclusion: { in: BILLING_CYCLES }
  validates :status, inclusion: { in: STATUSES }
  validates :start_date, presence: true

  before_validation :generate_contract_number, on: :create, if: -> { contract_number.blank? }

  scope :for_type, ->(type) { joins(:service_center).where(service_centers: { service_type: type }) }

  # Effective lifecycle — "terminated" is a manual admin action, everything
  # else is derived from today vs the contract's date window so nobody has
  # to remember to flip a status when a contract lapses.
  def effective_status
    return "terminated" if status == "terminated"
    return "expired" if end_date.present? && end_date < Date.current
    return "pending" if start_date > Date.current
    "active"
  end

  def total_paid
    service_center_payments.paid.sum(:amount)
  end

  def total_pending
    service_center_payments.pending.sum(:amount)
  end

  # Simplified 3-state badge ("ปกติ/ใกล้หมดอายุ/หมดอายุ") for list views —
  # collapses effective_status's 4 lifecycle states down to what a partner
  # actually needs to react to. A not-yet-started (pending) contract reads
  # as "normal" rather than "expired" since there's nothing wrong with it.
  def near_expiry_status
    return "expired" if %w[expired terminated].include?(effective_status)
    return "normal" if effective_status == "pending"
    end_date.present? && end_date <= 30.days.from_now.to_date ? "expiring" : "normal"
  end

  # Payment status of the most recent recorded payment — no payment on
  # file at all reads as "unpaid" rather than blank.
  def payment_status
    latest = service_center_payments.order(paid_at: :desc, created_at: :desc).first
    latest&.status || "unpaid"
  end

  # Human label for the contract's billing window, e.g. "ລາຍ 6 ເດືອນ".
  def package_label
    return "ບໍ່ມີກຳນົດ" unless end_date.present?
    months = (end_date.year - start_date.year) * 12 + (end_date.month - start_date.month)
    case months
    when 3  then "ລາຍ 3 ເດືອນ"
    when 6  then "ລາຍ 6 ເດືອນ"
    when 12 then "ລາຍ 1 ປີ"
    else "ກຳນົດເອງ (#{months} ເດືອນ)"
    end
  end

  # A center's contract "still covers" it if it's currently active, or if
  # payment for the current period has been recorded but is still pending
  # confirmation (grace period — a late bank transfer shouldn't instantly
  # hide the listing).
  def visible?
    effective_status == "active"
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id service_center_id contract_number rent_amount billing_cycle start_date end_date status created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[service_center service_center_payments]
  end

  private

  def generate_contract_number
    year = Date.current.year
    last = ServiceCenterContract.where("contract_number LIKE ?", "CT-#{year}-%").order(:contract_number).last
    seq = last ? last.contract_number.split("-").last.to_i + 1 : 1
    self.contract_number = "CT-#{year}-#{seq.to_s.rjust(4, '0')}"
  end
end
