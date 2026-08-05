class Vehicle < ApplicationRecord
  belongs_to :user
  has_many :road_taxes, dependent: :destroy
  has_many :insurances, dependent: :destroy
  has_many :inspections, dependent: :destroy
  has_many :documents, dependent: :destroy

  has_one_attached :registration_front
  has_one_attached :registration_back

  validates :plate_number, presence: true

  VEHICLE_TYPES = %w[car motorcycle truck].freeze

  def self.ransackable_attributes(auth_object = nil)
    %w[id plate_number plate_type brand model year color vehicle_type created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user road_taxes insurances inspections]
  end
end
