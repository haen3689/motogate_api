class AddUniqueIndexToVehicleBrandsName < ActiveRecord::Migration[8.1]
  # VehicleBrand validates uniqueness of :name, but nothing backed it in the
  # database — it was the only unbacked uniqueness validation in the schema.
  # A Rails uniqueness validation is a read-then-write, so concurrent admin
  # creates (or a re-run of db/seeds.rb) could still insert duplicates, which
  # then appear twice in the app's brand picker.
  #
  # Nothing references vehicle_brands by id — vehicles store the brand as a
  # plain string — so collapsing duplicates is just a delete, with no rows to
  # repoint.
  def up
    execute <<~SQL
      DELETE FROM vehicle_brands
      WHERE name IS NOT NULL
        AND id NOT IN (
          SELECT MIN(id) FROM vehicle_brands WHERE name IS NOT NULL GROUP BY name
        )
    SQL

    add_index :vehicle_brands, :name, unique: true
  end

  def down
    remove_index :vehicle_brands, :name
  end
end
