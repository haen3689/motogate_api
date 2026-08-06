class AddSeatRangeToInsurancePackages < ActiveRecord::Migration[8.1]
  def change
    add_column :insurance_packages, :min_seats, :integer
    add_column :insurance_packages, :max_seats, :integer
  end
end
