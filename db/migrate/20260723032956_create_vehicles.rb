class CreateVehicles < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :plate_number
      t.string :brand
      t.string :model
      t.integer :year
      t.string :color
      t.string :vehicle_type

      t.timestamps
    end
  end
end
