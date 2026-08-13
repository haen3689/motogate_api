class Transaction < ApplicationRecord
  belongs_to :user
  # Nil for external_upload road tax entries (log_transaction! in
  # transaction_logging.rb) — those are a manually uploaded proof image
  # with no BCEL payment behind them.
  belongs_to :payment, optional: true

  TYPES = %w[road_tax insurance inspection service vehicle_fee].freeze
  STATUSES = %w[pending success failed].freeze
  validates :transaction_type, :amount, :status, presence: true
  validates :transaction_type, inclusion: { in: TYPES }
  validates :status, inclusion: { in: STATUSES }

  # uuid/invoice_id/bcel_transaction_id/fccref only exist on the linked
  # Payment (if any) — never duplicated onto Transaction itself, so this
  # is the one place that reads across the association for display.
  def payment_refs
    return {} unless payment

    {
      reference_no: payment.bcel_transaction_id.presence || payment.uuid,
      invoice_no: payment.invoice_id,
      merchant_ref_no: payment.fccref,
    }
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id transaction_type amount status reference_id payment_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user payment]
  end
end
