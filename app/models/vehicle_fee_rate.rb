class VehicleFeeRate < ApplicationRecord
  validates :vehicle_type, presence: true, uniqueness: true, inclusion: { in: Vehicle::VEHICLE_TYPES }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Ensures every vehicle type has a row so the settings page always shows
  # all of them, even ones nobody has customized yet.
  def self.ensure_defaults!
    Vehicle::VEHICLE_TYPES.each do |type|
      find_or_create_by!(vehicle_type: type) { |r| r.amount = 200_000 }
    end
  end

  def self.for_vehicle(vehicle)
    find_by(vehicle_type: vehicle.vehicle_type)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id vehicle_type amount created_at updated_at]
  end
end
