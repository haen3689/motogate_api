class CreateServiceCenters < ActiveRecord::Migration[8.1]
  def change
    create_table :service_centers do |t|
      t.string :name
      t.text :location
      t.string :phone
      t.string :logo
      t.string :owner_name
      t.string :status
      t.decimal :rating
      t.string :service_type
      t.decimal :lat
      t.decimal :lng

      t.timestamps
    end
  end
end
