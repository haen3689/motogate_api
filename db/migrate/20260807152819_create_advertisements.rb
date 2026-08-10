class CreateAdvertisements < ActiveRecord::Migration[8.1]
  def change
    create_table :advertisements do |t|
      t.string :title, null: false
      t.string :subtitle
      t.string :image
      t.string :link_url
      t.integer :position, default: 0, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
