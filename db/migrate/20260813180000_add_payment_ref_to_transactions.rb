class AddPaymentRefToTransactions < ActiveRecord::Migration[8.1]
  def change
    # Optional — external_upload road tax transactions (log_transaction! in
    # transaction_logging.rb) have no BCEL payment at all, only a manually
    # uploaded proof image, so this stays nil for those.
    add_reference :transactions, :payment, foreign_key: true, null: true
  end
end
