class AddWeightToVehicles < ActiveRecord::Migration[8.1]
  def change
    add_column :vehicles, :weight, :string
  end
end
