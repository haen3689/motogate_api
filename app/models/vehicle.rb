class Vehicle < ApplicationRecord
  belongs_to :user
  has_many :road_taxes, dependent: :destroy
  has_many :insurances, dependent: :destroy
  has_many :inspections, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :vehicle_shares, dependent: :destroy
  has_many :shared_users, through: :vehicle_shares, source: :user

  has_one_attached :registration_front
  has_one_attached :registration_back
  has_one_attached :front_photo
  has_one_attached :transport_booklet

  validates :plate_number, presence: true

  VEHICLE_TYPES = %w[motorcycle car pickup suv van bus towtruck trailer].freeze

  def self.ransackable_attributes(auth_object = nil)
    %w[id plate_number plate_type brand model year color vehicle_type created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user road_taxes insurances inspections]
  end
end
