class RoadTax < ApplicationRecord
  include PayableByPayment

  belongs_to :vehicle
  has_one_attached :proof_image

  STATUSES = %w[pending paid expired].freeze
  # app_payment    — paid through BCEL OnePay in-app, price computed from RoadTaxRate;
  #                  stays "pending" until the Payment is confirmed.
  # external_upload — user already paid at a physical transport office and uploaded proof;
  #                    marked paid immediately, kept separate so a future real transport-department
  #                    integration can distinguish/reconcile the two sources.
  SOURCES = %w[app_payment external_upload].freeze
  validates :tax_year, :amount, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :source, inclusion: { in: SOURCES }, allow_nil: true

  def self.ransackable_attributes(auth_object = nil)
    %w[id tax_year amount service_fee status source paid_at expired_at vehicle_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vehicle]
  end

  def payment_owner
    vehicle.user
  end

  # Called by Payment#mark_paid! once BCEL confirms the payment via callback.
  def mark_paid_from_payment!(payment)
    update!(status: "paid", paid_at: Time.current)
    vehicle.user.transactions.create!(
      transaction_type: "road_tax",
      amount: payment.amount,
      status: "success",
      reference: vehicle.plate_number,
      description: "ຄ່າທາງ ປີ #{tax_year} - #{vehicle.plate_number}",
      payment: payment
    )
  rescue StandardError => e
    Rails.logger.error("[RoadTax] Failed to finalize payment #{payment.uuid}: #{e.message}")
  end
end
