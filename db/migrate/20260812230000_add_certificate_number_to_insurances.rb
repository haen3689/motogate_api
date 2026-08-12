class AddCertificateNumberToInsurances < ActiveRecord::Migration[8.1]
  def change
    add_column :insurances, :certificate_number, :string
    add_index :insurances, :certificate_number, unique: true
  end
end
