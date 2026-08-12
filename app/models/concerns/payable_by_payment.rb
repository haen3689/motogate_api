# Included by any model that can be paid for through the central Payment
# module (RoadTax, Insurance, ...). Including models must implement
# `mark_paid_from_payment!(payment)` to apply their own status transition
# and history logging once BCEL confirms the payment.
module PayableByPayment
  extend ActiveSupport::Concern

  included do
    has_many :payments, as: :payable, dependent: :destroy
  end
end
