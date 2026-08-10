class AddLastAnnouncementsSeenAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :last_announcements_seen_at, :datetime
  end
end
