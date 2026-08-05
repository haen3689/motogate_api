class CreatePlateTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :plate_types do |t|
      t.string :plate_code, null: false
      t.string :name,       null: false
      t.string :color_class, null: false, default: 'plate-yellow'
      t.boolean :show_province, null: false, default: true
      t.string :status,     null: false, default: 'active'
      t.integer :position,  null: false, default: 0

      t.timestamps
    end
  end
end
