class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.string :name
      t.string :document_type
      t.string :file_url

      t.timestamps
    end
  end
end
