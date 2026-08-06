class CreateRoadTaxRates < ActiveRecord::Migration[8.1]
  def change
    create_table :road_tax_rates do |t|
      t.string :vehicle_type
      t.integer :min_cc
      t.integer :max_cc
      t.integer :min_seats
      t.integer :max_seats
      t.decimal :min_weight
      t.decimal :max_weight
      t.decimal :price
      t.string :status

      t.timestamps
    end
  end
end
