class AddEngineFieldsToVehicles < ActiveRecord::Migration[8.1]
  def change
    add_column :vehicles, :engine_number, :string
    add_column :vehicles, :chassis_number, :string
    add_column :vehicles, :cc, :string
  end
end
