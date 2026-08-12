class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :payable, polymorphic: true, null: false
      t.string :uuid, null: false
      t.string :provider, null: false, default: "bcel_onepay"
      t.string :status, null: false, default: "pending"
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :ccy, null: false, default: "LAK"
      t.string :terminal_id
      t.string :invoice_id
      t.string :description
      t.datetime :expires_at
      t.datetime :paid_at

      # From BCEL's PubNub callback payload
      t.string :bcel_transaction_id
      t.string :payer_name
      t.string :payer_phone
      t.string :ticket
      t.string :fccref
      t.text :callback_payload

      t.datetime :voided_at
      t.decimal :refunded_amount, precision: 12, scale: 2
      t.string :refund_reference

      t.timestamps
    end

    add_index :payments, :uuid, unique: true
    add_index :payments, :status
  end
end
