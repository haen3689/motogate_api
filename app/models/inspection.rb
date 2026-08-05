class Inspection < ApplicationRecord
  belongs_to :vehicle

  STATUSES = %w[pending confirmed completed cancelled].freeze
  validates :center_name, :appointment_at, :status, presence: true
  validates :status, inclusion: { in: STATUSES }

  def self.ransackable_attributes(auth_object = nil)
    %w[id center_name appointment_at status notes created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vehicle]
  end
end
