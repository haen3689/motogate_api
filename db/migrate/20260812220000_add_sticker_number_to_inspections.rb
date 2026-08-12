class AddStickerNumberToInspections < ActiveRecord::Migration[8.1]
  def change
    add_column :inspections, :sticker_number, :string
  end
end
