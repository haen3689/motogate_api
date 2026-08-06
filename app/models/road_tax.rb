class RoadTax < ApplicationRecord
  belongs_to :vehicle
  has_one_attached :proof_image

  STATUSES = %w[pending paid expired].freeze
  # app_payment    — paid through the in-app (mock) payment flow, price computed from RoadTaxRate
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
end
