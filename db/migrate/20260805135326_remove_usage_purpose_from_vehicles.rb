class RemoveUsagePurposeFromVehicles < ActiveRecord::Migration[8.0]
  def change
    remove_column :vehicles, :usage_purpose, :string
  end
end
