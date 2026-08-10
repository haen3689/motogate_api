class Role < ApplicationRecord
  has_many :permissions, dependent: :destroy
  has_many :admin_users, foreign_key: :custom_role_id, dependent: :nullify, inverse_of: :custom_role
  accepts_nested_attributes_for :permissions

  validates :key, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_]+\z/, message: "ໃຊ້ໄດ້ສະເພາະ a-z 0-9 _ ເທົ່ານັ້ນ" }
  validates :name, presence: true

  before_validation :generate_key, on: :create, if: -> { key.blank? && name.present? }

  # Ensures every role has a Permission row (default all-false, unread) for
  # every resource in the catalog, so the edit form always renders the full
  # matrix instead of only showing resources someone happened to save before.
  def ensure_full_permission_set!
    existing = permissions.pluck(:resource)
    Permission::CATALOG.keys.each do |key|
      next if existing.include?(key)
      permissions.create!(resource: key, can_read: false)
    end
  end

  def can?(resource, action)
    perm = permissions.find { |p| p.resource == resource.to_s }
    return false unless perm
    case action.to_sym
    when :read   then perm.can_read
    when :create then perm.can_create
    when :update then perm.can_update
    when :delete then perm.can_delete
    else false
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id key name created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[admin_users permissions]
  end

  private

  def generate_key
    self.key = name.to_s.strip.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "")
  end
end
