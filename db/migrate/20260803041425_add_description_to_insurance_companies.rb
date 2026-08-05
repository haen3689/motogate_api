class AddDescriptionToInsuranceCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :insurance_companies, :description, :text
  end
end
