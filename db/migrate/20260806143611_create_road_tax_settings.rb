class CreateRoadTaxSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :road_tax_settings do |t|
      t.string :fee_type
      t.decimal :flat_amount
      t.decimal :percent_rate

      t.timestamps
    end
  end
end
