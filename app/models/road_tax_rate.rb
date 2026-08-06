class RoadTaxRate < ApplicationRecord
  VEHICLE_TYPES = %w[motorcycle car pickup suv van bus towtruck trailer].freeze
  SEAT_BASED_TYPES = %w[van bus].freeze
  WEIGHT_BASED_TYPES = %w[towtruck trailer].freeze
  STATUSES = %w[active inactive].freeze

  scope :active, -> { where(status: 'active') }

  def self.for_vehicle(vehicle)
    active.find do |rate|
      next false if rate.vehicle_type.present? && rate.vehicle_type != vehicle.vehicle_type

      if SEAT_BASED_TYPES.include?(rate.vehicle_type)
        seats = vehicle.seat_count.to_i
        next false if rate.min_seats && seats < rate.min_seats
        next false if rate.max_seats && seats > rate.max_seats
      elsif WEIGHT_BASED_TYPES.include?(rate.vehicle_type)
        weight = vehicle.weight.to_f
        next false if rate.min_weight && weight < rate.min_weight
        next false if rate.max_weight && weight > rate.max_weight
      else
        cc = vehicle.cc.to_i
        next false if rate.min_cc && cc < rate.min_cc
        next false if rate.max_cc && cc > rate.max_cc
      end

      true
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id vehicle_type min_cc max_cc min_seats max_seats min_weight max_weight price status created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
