class CreatePartnerApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :partner_applications do |t|
      t.string :business_name, null: false
      t.string :service_type, null: false
      t.string :owner_name
      t.string :phone
      t.string :location
      t.string :status, null: false, default: "pending"
      t.text :notes
      t.references :service_center, null: true, foreign_key: true
      t.references :reviewed_by, null: true, foreign_key: { to_table: :admin_users }
      t.datetime :reviewed_at

      t.timestamps
    end

    add_index :partner_applications, :status
    add_index :partner_applications, :service_type
  end
end
