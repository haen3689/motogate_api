class InspectionService < ApplicationRecord
  belongs_to :inspection_center

  VEHICLE_TYPES = %w[motorcycle car pickup suv van bus towtruck trailer].freeze
  STATUSES = %w[active inactive].freeze

  scope :active, -> { where(status: 'active') }

  def self.for_vehicle(vehicle)
    active.find do |service|
      next false if service.vehicle_type.present? && service.vehicle_type != vehicle.vehicle_type

      cc = vehicle.cc.to_i
      next false if service.min_cc && cc < service.min_cc
      next false if service.max_cc && cc > service.max_cc

      true
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id name vehicle_type min_cc max_cc price detail status inspection_center_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[inspection_center]
  end
end
