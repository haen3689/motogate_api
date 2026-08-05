class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :first_name,    :string
    add_column :users, :last_name,     :string
    add_column :users, :gender,        :string
    add_column :users, :province,      :string
    add_column :users, :district,      :string
    add_column :users, :village,       :string
    add_column :users, :id_type,       :string, default: 'national_id'
    add_column :users, :id_number,     :string
    add_column :users, :id_expiry_date, :date
  end
end
