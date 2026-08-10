class CreateRolesAndPermissions < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.timestamps
    end
    add_index :roles, :key, unique: true

    create_table :permissions do |t|
      t.references :role, null: false, foreign_key: true
      t.string :resource, null: false
      t.boolean :can_read,   default: true,  null: false
      t.boolean :can_create, default: false, null: false
      t.boolean :can_update, default: false, null: false
      t.boolean :can_delete, default: false, null: false
      t.timestamps
    end
    add_index :permissions, [:role_id, :resource], unique: true

    add_reference :admin_users, :custom_role, null: true, foreign_key: { to_table: :roles }
  end
end
