class AddExtraDetailFieldsToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :owner_name, :string
    add_column :vehicles, :fuel_type, :string
    add_column :vehicles, :seat_count, :string
    add_column :vehicles, :axle_count, :string
    add_column :vehicles, :cylinder_count, :string
    add_column :vehicles, :usage_purpose, :string
    add_column :vehicles, :registration_expiry_date, :date
  end
end
