class CreateServiceCenterContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :service_center_contracts do |t|
      t.references :service_center, null: false, foreign_key: true
      t.string :contract_number, null: false
      t.decimal :rent_amount, precision: 12, scale: 2, null: false, default: 0
      t.string :billing_cycle, null: false, default: "monthly"
      t.date :start_date, null: false
      t.date :end_date
      t.string :status, null: false, default: "active"
      t.text :notes

      t.timestamps
    end

    add_index :service_center_contracts, :contract_number, unique: true
    add_index :service_center_contracts, :status

    create_table :service_center_payments do |t|
      t.references :service_center_contract, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.date :paid_at, null: false
      t.string :period_label
      t.text :notes

      t.timestamps
    end
  end
end
