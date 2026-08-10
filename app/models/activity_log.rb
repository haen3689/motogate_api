class ActivityLog < ApplicationRecord
  belongs_to :admin_user

  ACTIONS = %w[created updated deleted].freeze

  def self.ransackable_attributes(auth_object = nil)
    %w[id admin_user_id action resource_type resource_id resource_label created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[admin_user]
  end
end
