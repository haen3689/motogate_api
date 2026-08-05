class CreateInspectionCenters < ActiveRecord::Migration[8.1]
  def change
    create_table :inspection_centers do |t|
      t.string :name
      t.text :location
      t.string :phone
      t.string :logo
      t.string :status
      t.integer :capacity_per_day

      t.timestamps
    end
  end
end
