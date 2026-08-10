class AddStatusToServiceCenterPayments < ActiveRecord::Migration[8.1]
  def change
    add_column :service_center_payments, :status, :string, default: "paid", null: false
  end
end
