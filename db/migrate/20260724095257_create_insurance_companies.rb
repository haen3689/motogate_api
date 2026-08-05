class CreateInsuranceCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :insurance_companies do |t|
      t.string :name
      t.string :logo
      t.string :phone
      t.string :email
      t.string :status

      t.timestamps
    end
  end
end
