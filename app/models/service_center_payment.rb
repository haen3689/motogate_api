class ServiceCenterPayment < ApplicationRecord
  belongs_to :service_center_contract

  STATUSES = %w[pending paid].freeze
  METHODS  = ["BCEL One (ໂອນ)", "APB Bank (ໂອນ)", "LDB Bank (ໂອນ)", "ເງິນສົດ (Cash)", "ອື່ນໆ"].freeze

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :paid_at, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :for_type, ->(type) { joins(service_center_contract: :service_center).where(service_centers: { service_type: type }) }
  scope :pending, -> { where(status: "pending") }
  scope :paid,    -> { where(status: "paid") }

  # Not a stored sequence — just a stable, human-friendly reference derived
  # from the record itself so every payment reads like a real invoice.
  def invoice_no
    "INV-#{paid_at.year}-#{id.to_s.rjust(3, '0')}"
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id service_center_contract_id amount paid_at period_label status payment_method created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[service_center_contract]
  end
end
