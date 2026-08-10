class AddServiceCenterIdToAdminUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :admin_users, :service_center, foreign_key: true, null: true
  end
end
