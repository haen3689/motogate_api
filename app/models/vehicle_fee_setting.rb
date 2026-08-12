class VehicleFeeSetting < ApplicationRecord
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Single-row settings table — always the same record, created with a sane
  # default on first access so the admin never has to "create" it manually.
  def self.current
    first_or_create!(amount: 200_000)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id amount created_at updated_at]
  end
end
