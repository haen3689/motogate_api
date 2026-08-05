class Insurance < ApplicationRecord
  belongs_to :vehicle

  STATUSES = %w[pending active expired cancelled].freeze
  validates :company, :package, :amount, :status, presence: true
  validates :status, inclusion: { in: STATUSES }

  def self.ransackable_attributes(auth_object = nil)
    %w[id amount company package status start_date end_date vehicle_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vehicle]
  end
end
