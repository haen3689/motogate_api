class AddStickerToInspections < ActiveRecord::Migration[8.1]
  def change
    add_column :inspections, :sticker, :string
  end
end
