class ReplaceVehicleFeeSettingWithRates < ActiveRecord::Migration[8.1]
  def change
    drop_table :vehicle_fee_settings, if_exists: true

    create_table :vehicle_fee_rates do |t|
      t.string :vehicle_type, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false, default: 200_000

      t.timestamps
    end

    add_index :vehicle_fee_rates, :vehicle_type, unique: true
  end
end
