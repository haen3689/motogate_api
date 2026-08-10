class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :trackable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[admin partner insurance service_partner staff superadmin].freeze

  belongs_to :inspection_center, optional: true
  belongs_to :insurance_company, optional: true
  belongs_to :service_center, optional: true
  belongs_to :custom_role, class_name: "Role", optional: true, inverse_of: :admin_users
  has_many :support_cases, dependent: :nullify
  validates :role, inclusion: { in: ROLES }
  validates :inspection_center, presence: true, if: -> { role == "partner" }
  validates :insurance_company, presence: true, if: -> { role == "insurance" }
  validates :service_center, presence: true, if: -> { role == "service_partner" }
  validates :custom_role, presence: true, if: -> { role == "staff" }

  scope :support_agents, -> { where(role: "admin", is_support_agent: true) }

  def partner?
    role == "partner"
  end

  def insurance?
    role == "insurance"
  end

  def service_partner?
    role == "service_partner"
  end

  def staff?
    role == "staff"
  end

  def superadmin?
    role == "superadmin"
  end

  def admin?
    role == "admin"
  end

  # True for accounts that get the full, unrestricted admin panel — plain
  # "admin" and "superadmin" both do; superadmin additionally manages
  # Roles & Permissions (see RolePermissionAccessControl).
  def unrestricted?
    admin? || superadmin?
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id email role inspection_center_id insurance_company_id service_center_id custom_role_id is_support_agent support_online created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[inspection_center insurance_company service_center custom_role support_cases]
  end
end
