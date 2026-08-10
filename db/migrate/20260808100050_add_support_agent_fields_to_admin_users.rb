class AddSupportAgentFieldsToAdminUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_users, :is_support_agent, :boolean, default: false, null: false
    add_column :admin_users, :support_online, :boolean, default: false, null: false
  end
end
