class CreateVehicleFeeSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicle_fee_settings do |t|
      t.decimal :amount, precision: 12, scale: 2, null: false, default: 200_000

      t.timestamps
    end
  end
end
