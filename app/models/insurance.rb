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
    %w[id amount company package status certificate_number start_date end_date vehicle_id insurance_company_id created_at updated_at]
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
    update!(
      status: "active",
      start_date: start,
      end_date: start >> duration,
      certificate_number: generate_certificate_number
    )
    vehicle.user.transactions.create!(
      transaction_type: "insurance",
      amount: payment.amount,
      status: "success",
      reference: vehicle.plate_number,
      description: "ປະກັນໄພ #{package} - #{vehicle.plate_number}",
      payment: payment
    )
  end
  # NB: no blanket rescue here on purpose. This runs inside the transaction in
  # Payment#mark_paid!, so swallowing a failed write left the connection in an
  # aborted state while telling the caller the payment had been finalized: the
  # policy stayed pending, no Transaction row was written, and on PostgreSQL
  # the enclosing COMMIT degraded to a rollback that discarded even the
  # Payment's own "paid" flag — all silently, for a payment the customer had
  # really made. Letting it raise rolls the whole thing back honestly, and the
  # reconcile pass retries the callback later. Genuinely best-effort steps
  # (SMS, ActionCable) rescue individually instead.

  private

  def set_insurance_company
    self.insurance_company = InsuranceCompany.find_by(name: company)
  end

  # Assigned only once a policy actually becomes active (not at pending/cart
  # creation) so numbers aren't wasted on abandoned purchases. Resets to 1
  # each year, same convention as ServiceCenterContract#generate_contract_number.
  def generate_certificate_number
    return certificate_number if certificate_number.present?

    year = Date.current.strftime("%y")

    # Read-then-write against a column with a unique index. Two payments can
    # finalize at the same moment — the live PubNub subscribe callback and the
    # reconcile fetch callback both run on pubnub-owned threads — and both
    # would compute the same next sequence, with one hitting RecordNotUnique.
    # A transaction-scoped advisory lock serialises them; it is released
    # automatically at commit or rollback. Outside a transaction it is a no-op,
    # which is no worse than the previous behaviour.
    self.class.with_advisory_lock_on("insurance_certificate_#{year}")

    last = Insurance.where("certificate_number LIKE ?", "MG#{year}-%").order(:certificate_number).last
    seq = last ? last.certificate_number.split("-").last.to_i + 1 : 1
    "MG#{year}-#{seq.to_s.rjust(6, '0')}"
  end
end
