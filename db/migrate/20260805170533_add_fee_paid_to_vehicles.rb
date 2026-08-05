class AddFeePaidToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :fee_paid, :boolean, default: false, null: false
  end
end
