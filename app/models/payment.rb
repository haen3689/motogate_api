class Payment < ApplicationRecord
  belongs_to :payable, polymorphic: true

  PROVIDERS = %w[bcel_onepay].freeze
  STATUSES = %w[pending paid void refunded expired failed].freeze

  before_validation :ensure_uuid, on: :create

  validates :uuid, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }
  validates :provider, inclusion: { in: PROVIDERS }

  scope :pending, -> { where(status: "pending") }
  scope :paid, -> { where(status: "paid") }

  def expired?
    status == "pending" && expires_at.present? && expires_at.past?
  end

  # Regenerated on every read rather than stored, so its embedded expiry
  # (BCEL field "03") always reflects the time actually left.
  def qr_code
    return nil unless status == "pending" && !expired?

    remaining_minutes = [((expires_at - Time.current) / 60).ceil, 1].max
    Payments::BcelOnePay::QrBuilder.new(
      transaction_id: uuid,
      invoice_id: invoice_id.presence || uuid,
      terminal_id: terminal_id.to_s,
      amount: amount,
      description: description.to_s,
      expire_minutes: remaining_minutes
    ).build
  end

  def deeplink
    qr = qr_code
    qr && "onepay://qr/#{qr}"
  end

  def as_app_json
    {
      uuid: uuid,
      status: status,
      amount: amount,
      ccy: ccy,
      expires_at: expires_at,
      paid_at: paid_at,
      qr_code: qr_code,
      deeplink: deeplink
    }
  end

  # Idempotent — BCEL's PubNub callback can be redelivered (e.g. on client
  # reconnect within the 1hr replay window), so re-marking an already-paid
  # payment must be a no-op rather than double-firing payable side effects.
  def mark_paid!(callback_data)
    return true if status == "paid"

    transaction do
      update!(
        status: "paid",
        paid_at: Time.current,
        bcel_transaction_id: callback_data["id"]&.to_s,
        payer_name: callback_data["name"],
        payer_phone: callback_data["phone"],
        ticket: callback_data["ticket"],
        fccref: callback_data["fccref"],
        callback_payload: callback_data.to_json
      )
      payable.mark_paid_from_payment!(self) if payable.respond_to?(:mark_paid_from_payment!)
    end
    true
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id uuid provider status amount ccy payable_type payable_id paid_at created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[payable]
  end

  private

  def ensure_uuid
    self.uuid ||= "MG#{SecureRandom.hex(10).upcase}"
  end
end
