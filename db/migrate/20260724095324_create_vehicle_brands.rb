class CreateVehicleBrands < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicle_brands do |t|
      t.string :name
      t.string :status

      t.timestamps
    end
  end
end
