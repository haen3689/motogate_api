class InsurancePackage < ApplicationRecord
  belongs_to :insurance_company

  VEHICLE_TYPES = %w[car motorcycle truck].freeze
  STATUSES = %w[active inactive].freeze

  scope :active, -> { where(status: 'active') }

  def self.ransackable_attributes(auth_object = nil)
    %w[id name vehicle_type min_cc max_cc price coverage duration_months status insurance_company_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[insurance_company]
  end
end
