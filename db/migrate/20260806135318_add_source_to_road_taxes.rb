class AddSourceToRoadTaxes < ActiveRecord::Migration[8.1]
  def change
    add_column :road_taxes, :source, :string
  end
end
