class AddSpecialtyToServiceCenters < ActiveRecord::Migration[8.1]
  def change
    add_column :service_centers, :specialty, :string
  end
end
