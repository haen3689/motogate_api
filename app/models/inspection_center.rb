class InspectionCenter < ApplicationRecord
  has_many :inspection_services, dependent: :destroy

  scope :active, -> { where(status: 'active') }

  def self.ransackable_attributes(auth_object = nil)
    %w[id name location phone status]
  end
end
