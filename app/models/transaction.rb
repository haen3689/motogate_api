class Transaction < ApplicationRecord
  belongs_to :user

  TYPES = %w[road_tax insurance inspection service vehicle_fee].freeze
  STATUSES = %w[pending success failed].freeze
  validates :transaction_type, :amount, :status, presence: true
  validates :transaction_type, inclusion: { in: TYPES }
  validates :status, inclusion: { in: STATUSES }

  def self.ransackable_attributes(auth_object = nil)
    %w[id transaction_type amount status reference_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end
end
