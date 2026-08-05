class ServiceCenter < ApplicationRecord
  scope :active,  -> { where(status: 'active') }
  scope :garage,  -> { where(service_type: 'garage') }
  scope :towing,  -> { where(service_type: 'towing') }
  scope :dealer,  -> { where(service_type: 'dealer') }

  def self.ransackable_attributes(auth_object = nil)
    %w[id name location service_type status]
  end
end
