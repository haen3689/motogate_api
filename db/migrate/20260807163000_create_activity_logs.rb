class CreateActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_logs do |t|
      t.references :admin_user, null: false, foreign_key: true
      t.string :action, null: false
      t.string :resource_type, null: false
      t.bigint :resource_id
      t.string :resource_label

      t.timestamps
    end

    add_index :activity_logs, :resource_type
    add_index :activity_logs, :created_at
  end
end
