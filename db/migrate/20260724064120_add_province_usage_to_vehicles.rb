class AddProvinceUsageToVehicles < ActiveRecord::Migration[8.1]
  def change
    add_column :vehicles, :province, :string
    add_column :vehicles, :usage_type, :string
  end
end
