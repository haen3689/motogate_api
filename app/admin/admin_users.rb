ActiveAdmin.register AdminUser do
  menu label: "ຜູ້ດູແລລະບົບ", if: -> { !current_admin_user.partner? }

  permit_params :email, :password, :password_confirmation, :role, :inspection_center_id

  index do
    selectable_column
    id_column
    column :email
    column("ບົດບາດ") { |u| u.partner? ? "Partner" : "Admin" }
    column("ສູນກວດກາເຕັກນິກ") { |u| u.inspection_center ? link_to(u.inspection_center.name, admin_inspection_center_path(u.inspection_center)) : "—" }
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :role, as: :select, collection: AdminUser::ROLES
  filter :inspection_center, as: :select, collection: -> { InspectionCenter.order(:name).pluck(:name, :id) }
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  show do
    attributes_table do
      row :id
      row :email
      row("ບົດບາດ") { |u| u.partner? ? "Partner" : "Admin" }
      row("ສູນກວດກາເຕັກນິກ") { |u| u.inspection_center ? link_to(u.inspection_center.name, admin_inspection_center_path(u.inspection_center)) : "—" }
      row :current_sign_in_at
      row :sign_in_count
      row :created_at
    end
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :role, as: :select, collection: AdminUser::ROLES, include_blank: false,
              hint: "Partner ຈະເຫັນສະເພາະລາຍການຈອງ ແລະ ຂໍ້ມູນສູນກວດກາຂອງຕົນເອງເທົ່ານັ້ນ"
      f.input :inspection_center, label: "ສູນກວດກາເຕັກນິກ (ສຳລັບ Partner ເທົ່ານັ້ນ)",
              collection: InspectionCenter.order(:name), include_blank: "— ບໍ່ກ່ຽວຂ້ອງ —"
    end
    f.actions
  end
end
