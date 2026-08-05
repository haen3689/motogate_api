class CreateRoadTaxes < ActiveRecord::Migration[8.1]
  def change
    create_table :road_taxes do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.integer :tax_year
      t.decimal :amount
      t.string :status
      t.date :expired_at

      t.timestamps
    end
  end
end
