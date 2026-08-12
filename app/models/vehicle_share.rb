class VehicleShare < ApplicationRecord
  belongs_to :vehicle
  belongs_to :user

  validates :user_id, uniqueness: { scope: :vehicle_id }
end
