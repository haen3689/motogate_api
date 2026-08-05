class RoadTax < ApplicationRecord
  belongs_to :vehicle

  STATUSES = %w[pending paid expired].freeze
  validates :tax_year, :amount, :status, presence: true
  validates :status, inclusion: { in: STATUSES }

  def self.ransackable_attributes(auth_object = nil)
    %w[id tax_year amount status expired_at vehicle_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vehicle]
  end
end
