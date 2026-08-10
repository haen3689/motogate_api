class CreateSupportTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :support_templates do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end
  end
end
