# Records a real entry in the unified "ປະຫວັດ" (transaction history) log
# shown in the app — RoadTax/Insurance/Inspection controllers call this
# right after their own record saves successfully. Best-effort: a logging
# failure must never break the actual booking/payment that already succeeded.
module TransactionLogging
  extend ActiveSupport::Concern

  private

  def log_transaction!(type:, amount:, reference:, description:)
    current_user.transactions.create!(
      transaction_type: type,
      amount: amount,
      status: "success",
      reference: reference,
      description: description
    )
  rescue => e
    Rails.logger.error("[TransactionLogging] Failed to log #{type} transaction: #{e.message}")
  end
end
