class AddPaymentMethodToServiceCenterPayments < ActiveRecord::Migration[8.1]
  def change
    add_column :service_center_payments, :payment_method, :string
  end
end
