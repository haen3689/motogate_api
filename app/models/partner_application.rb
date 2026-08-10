class PartnerApplication < ApplicationRecord
  STATUSES = %w[pending approved rejected].freeze
  SERVICE_TYPES = %w[garage dealer towing].freeze

  belongs_to :service_center, optional: true
  belongs_to :reviewed_by, class_name: "AdminUser", optional: true

  validates :business_name, presence: true
  validates :service_type, inclusion: { in: SERVICE_TYPES }
  validates :status, inclusion: { in: STATUSES }

  scope :for_type, ->(type) { where(service_type: type) }
  scope :pending, -> { where(status: "pending") }

  # Approving turns the application into a real (initially inactive)
  # ServiceCenter the admin can then finish setting up — the application
  # itself is never mutated into a center record, it just links to one.
  def approve!(reviewer)
    return false if status != "pending"

    ActiveRecord::Base.transaction do
      center = ServiceCenter.create!(
        name: business_name,
        owner_name: owner_name,
        phone: phone,
        location: location,
        service_type: service_type,
        status: "active"
      )
      update!(status: "approved", service_center: center, reviewed_by: reviewer, reviewed_at: Time.current)
    end
    true
  end

  def reject!(reviewer, reason: nil)
    return false if status != "pending"
    update!(status: "rejected", reviewed_by: reviewer, reviewed_at: Time.current, notes: reason.presence || notes)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id business_name service_type owner_name phone location status notes service_center_id reviewed_by_id reviewed_at created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[service_center reviewed_by]
  end
end
