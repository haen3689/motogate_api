class VehicleBrand < ApplicationRecord
  scope :active, -> { where(status: 'active') }
end
