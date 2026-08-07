class AddRoleToAdminUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_users, :role, :string, null: false, default: "admin"
    add_reference :admin_users, :inspection_center, foreign_key: true
  end
end
