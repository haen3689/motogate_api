class AddPaidAtToRoadTaxes < ActiveRecord::Migration[8.1]
  def change
    add_column :road_taxes, :paid_at, :date
  end
end
