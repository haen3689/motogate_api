class AddLatitudeLongitudeToInspectionCenters < ActiveRecord::Migration[8.1]
  def change
    add_column :inspection_centers, :latitude, :decimal, precision: 10, scale: 6
    add_column :inspection_centers, :longitude, :decimal, precision: 10, scale: 6
  end
end
