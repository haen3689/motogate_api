class OnboardingSlide < ApplicationRecord
  validates :title,    presence: true
  validates :subtitle, presence: true
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :active,   -> { where(active: true) }
  scope :ordered,  -> { order(:position) }

  def self.ransackable_attributes(auth_object = nil)
    %w[active created_at id image_url position subtitle title updated_at]
  end
end
