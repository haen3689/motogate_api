class AddCampaignFieldsToAdvertisements < ActiveRecord::Migration[8.1]
  def change
    add_column :advertisements, :placement, :string, default: "banner", null: false
    add_column :advertisements, :start_date, :date
    add_column :advertisements, :end_date, :date
    add_column :advertisements, :click_count, :integer, default: 0, null: false
    add_column :advertisements, :view_count, :integer, default: 0, null: false
  end
end
