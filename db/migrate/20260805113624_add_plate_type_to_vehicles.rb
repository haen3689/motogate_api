class AddPlateTypeToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :plate_type, :string
  end
end
