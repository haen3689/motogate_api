class AddReadByAdminToChatMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :chat_messages, :read_by_admin, :boolean, default: false, null: false
  end
end
