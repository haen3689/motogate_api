class AddWeightAndUsageTypeToInsurancePackages < ActiveRecord::Migration[8.1]
  def change
    add_column :insurance_packages, :min_weight, :decimal
    add_column :insurance_packages, :max_weight, :decimal
    add_column :insurance_packages, :usage_type, :string
  end
end
