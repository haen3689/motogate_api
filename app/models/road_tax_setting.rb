class RoadTaxSetting < ApplicationRecord
  FEE_TYPES = %w[flat percent].freeze
  validates :fee_type, inclusion: { in: FEE_TYPES }
  validates :flat_amount, :percent_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Single-row settings table — always the same record, created with sane
  # defaults on first access so the admin never has to "create" it manually.
  def self.current
    first_or_create!(fee_type: 'flat', flat_amount: 10_000, percent_rate: 5)
  end

  # ຄິດໄລ່ຄ່າທຳນຽມແພລດຟອມ ຈາກ base_amount (ລາຄາຄ່າທາງອ້າງອີງຂອງລົດຄັນນັ້ນ, ໃຊ້ສະເພາະໂໝດ percent)
  def compute_fee(base_amount)
    if fee_type == 'percent'
      ((percent_rate.to_f / 100.0) * base_amount.to_f).round(2)
    else
      flat_amount.to_f
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id fee_type flat_amount percent_rate created_at updated_at]
  end
end
