class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[admin partner].freeze

  belongs_to :inspection_center, optional: true
  validates :role, inclusion: { in: ROLES }
  validates :inspection_center, presence: true, if: -> { role == "partner" }

  def partner?
    role == "partner"
  end

  def admin?
    role == "admin"
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id email role inspection_center_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[inspection_center]
  end
end
