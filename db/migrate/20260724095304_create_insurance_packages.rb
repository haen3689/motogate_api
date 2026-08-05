class CreateInsurancePackages < ActiveRecord::Migration[8.1]
  def change
    create_table :insurance_packages do |t|
      t.integer :company_id
      t.string :name
      t.string :vehicle_type
      t.integer :min_cc
      t.integer :max_cc
      t.decimal :price
      t.text :coverage
      t.integer :duration_months
      t.string :status

      t.timestamps
    end
  end
end
