class CreateVehicleShares < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicle_shares do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :vehicle_shares, %i[vehicle_id user_id], unique: true
  end
end
