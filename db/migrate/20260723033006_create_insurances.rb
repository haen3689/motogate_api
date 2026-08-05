class CreateInsurances < ActiveRecord::Migration[8.1]
  def change
    create_table :insurances do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.string :company
      t.string :package
      t.decimal :amount
      t.string :status
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
