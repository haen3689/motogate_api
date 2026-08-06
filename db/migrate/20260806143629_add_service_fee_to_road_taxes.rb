class AddServiceFeeToRoadTaxes < ActiveRecord::Migration[8.1]
  def change
    add_column :road_taxes, :service_fee, :decimal
  end
end
