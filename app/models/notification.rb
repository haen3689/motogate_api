class Notification < ApplicationRecord
  belongs_to :user
  validates :title, :body, presence: true
  scope :unread, -> { where(read: false) }

  def self.ransackable_attributes(auth_object = nil)
    %w[body created_at id notification_type read title updated_at user_id]
  end
end
