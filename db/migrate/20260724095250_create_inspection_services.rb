class CreateInspectionServices < ActiveRecord::Migration[8.1]
  def change
    create_table :inspection_services do |t|
      t.integer :center_id
      t.string :name
      t.integer :min_cc
      t.integer :max_cc
      t.string :vehicle_type
      t.decimal :price
      t.string :status
      t.text :detail

      t.timestamps
    end
  end
end
