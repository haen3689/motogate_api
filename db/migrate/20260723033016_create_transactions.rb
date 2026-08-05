class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :transaction_type
      t.decimal :amount
      t.string :status
      t.string :reference
      t.string :description

      t.timestamps
    end
  end
end
