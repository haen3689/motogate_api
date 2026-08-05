class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :phone_number
      t.string :otp
      t.datetime :otp_expired_at
      t.boolean :verified
      t.string :name

      t.timestamps
    end
    add_index :users, :phone_number, unique: true
  end
end
