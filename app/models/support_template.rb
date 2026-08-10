class SupportTemplate < ApplicationRecord
  validates :title, :body, presence: true

  scope :ordered, -> { order(position: :asc, created_at: :asc) }

  def self.ransackable_attributes(auth_object = nil)
    %w[id title body position created_at updated_at]
  end
end
