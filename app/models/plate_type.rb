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
    plate-white-darkblue
    plate-red-underline plate-red
    plate-white-1percent plate-white-foreign plate-diplomat
  ].freeze

  # A real plate-type code is a short 1-4 character prefix (see the table
  # above — every one is ≤3 chars). Without this, the "ຈັດການປ້າຍ" admin
  # form makes it easy to fat-finger the long descriptive name into the
  # plate_code field instead of plate_type — that then round-trips
  # straight through PlateType.for_code and gets rendered next to every
  # matching vehicle's plate number on the vehicles list.
  #
  # plate_code is intentionally NOT unique — multiple active rows can
  # share the same code (e.g. two "ກກ" entries). When that happens,
  # #for_code below breaks the tie using `position`, so which one
  # actually applies is admin-controlled (via the "ລຳດັບ" field) rather
  # than left to undefined database ordering.
  validates :plate_code, length: { maximum: 6 }
  validates :color_class, inclusion: { in: COLOR_CLASSES }
  validates :status,     inclusion: { in: STATUSES }

  scope :active,   -> { where(status: 'active') }
  scope :ordered,  -> { order(:position, :plate_code) }

  # ຫາປະເພດປ້າຍ (ທີ່ເປີດໃຊ້ງານ) ຈາກລະຫັດໜ້າປ້າຍ — ໃຊ້ໃນໜ້າສະແດງລົດ
  # ເພື່ອໃຫ້ສີ + ການສະແດງແຂວງ ມາຈາກແຫຼ່ງດຽວ (ໜ້າ "ຈັດການປ້າຍ")
  def self.for_code(code)
    active.where(plate_code: code.to_s.strip).order(:position, :id).first
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id plate_code name color_class show_province status position created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
