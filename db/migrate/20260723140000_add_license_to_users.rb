class AddLicenseToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :license_number, :string
    add_column :users, :license_type, :string
    add_column :users, :license_expiry_date, :date
    add_column :users, :date_of_birth, :date
  end
end
