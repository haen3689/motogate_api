class PlateType < ApplicationRecord
  STATUSES     = %w[active inactive].freeze
  # 10 ປະເພດປ້າຍທະບຽນທາງການ ຂອງ ສປປ ລາວ (ຕາມຮູບອ້າງອີງ)
  # 1 plate-yellow          ເຫຼືອງ/ຕົວດຳ        ເອກະຊົນ ສ່ວນຕົວ
  # 2 plate-yellow-blue     ເຫຼືອງ/ຕົວຟ້າ        ເອກະຊົນຕ່າງດ້າວ
  # 3 plate-blue            ຟ້າ/ຕົວຂາວ           ລັດບໍລິຫານ
  # 4 plate-white           ຂາວ/ຕົວດຳ            ບໍລິສັດ 100%
  # 5 plate-red-underline   ແດງ/ຕົວຂາວ           ປກສ / ຕຳຫຼວດ
  # 6 plate-white-darkblue  ຂາວ/ຕົວຟ້າເຂັ້ມ       ຕ່າງປະເທດ (ອົງກອນ)
  # 7 plate-red             ແດງ/ຕົວຂາວ           ກອງທັບ
  # 8 plate-white-1percent  ຂາວ/ຕົວຟ້າ/ຂອບຟ້າ    ບໍລິສັດ 1%
  # 9 plate-diplomat        ຂາວ/ຕົວຟ້າ           ສະຖານທູດ
  # 10 plate-white-foreign  ຂາວ/ຕົວຟ້າ           ອົງການ ສະຫະປະຊາຊາດ
  COLOR_CLASSES = %w[
    plate-yellow plate-yellow-blue plate-blue plate-white
    plate-white-darkblue plate-white-lightblue
    plate-red-underline plate-red
    plate-white-1percent plate-white-foreign plate-diplomat
  ].freeze

  validates :plate_code, presence: true, uniqueness: true
  validates :name,       presence: true
  validates :color_class, inclusion: { in: COLOR_CLASSES }
  validates :status,     inclusion: { in: STATUSES }

  scope :active,   -> { where(status: 'active') }
  scope :ordered,  -> { order(:position, :plate_code) }

  # ຫາປະເພດປ້າຍ (ທີ່ເປີດໃຊ້ງານ) ຈາກລະຫັດໜ້າປ້າຍ — ໃຊ້ໃນໜ້າສະແດງລົດ
  # ເພື່ອໃຫ້ສີ + ການສະແດງແຂວງ ມາຈາກແຫຼ່ງດຽວ (ໜ້າ "ຈັດການປ້າຍ")
  def self.for_code(code)
    active.find_by(plate_code: code.to_s.strip)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id plate_code name color_class show_province status position created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
