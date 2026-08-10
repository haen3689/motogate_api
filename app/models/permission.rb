class Permission < ApplicationRecord
  belongs_to :role

  # The full catalog of resources a custom role can be granted access to —
  # key must match the ActiveAdmin controller_path suffix (e.g.
  # "admin/insurances" -> "insurances") so RolePermissionAccessControl can
  # look permissions up directly from the request. Also drives the
  # dynamically-rendered sidebar for the "staff" role and the permission
  # matrix on the Role edit form.
  CATALOG = {
    "users"               => { label: "ລູກຄ້າທັງໝົດ",        icon: "fa-users" },
    "vehicles"            => { label: "ລາຍການພາຫານະ",        icon: "fa-car" },
    "vehicle_brands"      => { label: "ຍີ່ຫໍ້ພາຫະນະ",         icon: "fa-trademark" },
    "inspections"         => { label: "ກວດສະພາບລົດ",         icon: "fa-car" },
    "inspection_centers"  => { label: "ສູນກວດກາເຕັກນິກ",     icon: "fa-warehouse" },
    "insurances"          => { label: "ປະກັນໄພ",             icon: "fa-shield-halved" },
    "insurance_companies" => { label: "ບໍລິສັດປະກັນໄພ",      icon: "fa-building-shield" },
    "road_taxes"          => { label: "ອາກອນຄ່າທາງ",         icon: "fa-road" },
    "road_tax_rates"      => { label: "ໄລຍະອາກອນຄ່າທາງ",     icon: "fa-percent" },
    "road_tax_settings"   => { label: "ຕັ້ງຄ່າ",              icon: "fa-cog" },
    "transactions"        => { label: "ໃບເກັບເງິນ",          icon: "fa-file-invoice-dollar" },
    "service_centers"     => { label: "ສູນບໍລິການ",          icon: "fa-store" },
    "announcements"       => { label: "ປະກາດ",                icon: "fa-bullhorn" },
    "advertisements"      => { label: "ໂຄສະນາ",              icon: "fa-rectangle-ad" },
    "reports"             => { label: "ລາຍງານ",               icon: "fa-chart-bar" },
    "support_chat"        => { label: "ຫ້ອງສົນທະນາ",         icon: "fa-comment-dots" },
    "activity_logs"       => { label: "ປະຫວັດ",               icon: "fa-history" },
    "admin_users"         => { label: "ຜູ້ດູແລລະບົບ",        icon: "fa-user-shield" },
  }.freeze

  validates :resource, presence: true, inclusion: { in: CATALOG.keys }
  validates :resource, uniqueness: { scope: :role_id }

  # Where a "staff" sidebar link / dashboard shortcut for this resource
  # should point. Almost everything is a normal index page, but
  # RoadTaxSetting is a singleton (only :show/:edit/:update, no :index —
  # see app/admin/road_tax_settings.rb) so it needs its record's edit path
  # instead, or url_for(action: :index) would raise a routing error.
  def self.path_for(resource_key)
    helpers = Rails.application.routes.url_helpers
    case resource_key
    when "road_tax_settings"
      helpers.admin_road_tax_setting_path(RoadTaxSetting.current)
    else
      helpers.url_for(controller: "/admin/#{resource_key}", action: :index, only_path: true)
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id role_id resource can_read can_create can_update can_delete created_at updated_at]
  end
end
