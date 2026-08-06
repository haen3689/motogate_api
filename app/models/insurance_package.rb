class InsurancePackage < ApplicationRecord
  belongs_to :insurance_company

  VEHICLE_TYPES = %w[motorcycle car pickup suv van bus towtruck trailer].freeze
  SEAT_BASED_TYPES = %w[van bus].freeze
  WEIGHT_BASED_TYPES = %w[towtruck trailer].freeze
  USAGE_TYPES = ['ນຳໃຊ້ສ່ວນຕົວ', 'ນຳໃຊ້ທຸລະກິດ'].freeze
  STATUSES = %w[active inactive].freeze

  scope :active, -> { where(status: 'active') }

  def self.ransackable_attributes(auth_object = nil)
    %w[id name vehicle_type min_cc max_cc min_seats max_seats min_weight max_weight usage_type
       price coverage duration_months status insurance_company_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[insurance_company]
  end
end
