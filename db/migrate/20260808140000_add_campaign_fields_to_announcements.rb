class AddCampaignFieldsToAnnouncements < ActiveRecord::Migration[8.1]
  def change
    add_column :announcements, :category, :string, default: "promotion", null: false
    add_column :announcements, :author, :string
    add_column :announcements, :view_count, :integer, default: 0, null: false
  end
end
