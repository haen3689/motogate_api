class ChatMessage < ApplicationRecord
  belongs_to :user
  validates :sender, :body, presence: true
  validates :sender, inclusion: { in: %w[user agent] }

  def self.ransackable_attributes(auth_object = nil)
    %w[id body sender created_at updated_at user_id]
  end
end
