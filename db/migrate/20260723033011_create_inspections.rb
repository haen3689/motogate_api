class CreateInspections < ActiveRecord::Migration[8.1]
  def change
    create_table :inspections do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.string :center_name
      t.string :center_address
      t.datetime :appointment_at
      t.string :status
      t.string :notes

      t.timestamps
    end
  end
end
