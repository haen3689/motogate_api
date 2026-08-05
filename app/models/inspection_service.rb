class InspectionService < ApplicationRecord
  belongs_to :inspection_center

  scope :active, -> { where(status: 'active') }
end
