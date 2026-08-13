module PlateBadgeHelper
  PlateBadge = Struct.new(:type, :number, :color_class, :show_province)

  NO_PROVINCE_TYPES = %w[ປກສ ກທ ຂຕ ສປຊ ສປ ສທ].freeze

  FALLBACK_COLOR_BY_TYPE = {
    %w[ຂ ຂໍ ຂ2 ຂ3 ຂ4 ກນ] => 'plate-yellow',
    %w[ກຄ ກຍ ກດ ກບ ກປ ດຂ ດຄ ດຍ ດດ ດທ] => 'plate-yellow-green',
    %w[ກຊ] => 'plate-blue',
    %w[ບຈ ບສ] => 'plate-white',
    %w[ກກ] => 'plate-yellow-blue',
    %w[ຂຕ] => 'plate-white-darkblue',
    %w[ກມ] => 'plate-white-lightblue',
    %w[ປກສ] => 'plate-red-underline',
    %w[ປກ ປຕ ກສ ກທ] => 'plate-red',
    %w[ສ1 1ສ] => 'plate-white-1percent',
    %w[ສທ ສປຊ] => 'plate-diplomat',
  }.freeze

  # Splits a vehicle's plate_number/plate_type into badge-ready parts and
  # resolves its display color — shared between the vehicles list and any
  # other admin page that needs to render the same plate badge (e.g. the
  # inspections/bookings list), so the parsing rules only live in one place.
  def plate_badge_for(vehicle)
    raw_plate = vehicle.plate_number.to_s.strip

    if vehicle.plate_type.present?
      type = vehicle.plate_type
      # plate_number sometimes already includes the type prefix (e.g. "ກດ1234"
      # when plate_type is "ກດ") — strip it so the badge doesn't show it twice.
      number = raw_plate.sub(/\A#{Regexp.escape(type)}\s*/, '').strip
      number = raw_plate if number.blank?
    else
      # No plate_type on file. Only split off a "type" prefix when the
      # operator actually typed one (a space-separated first word) — do NOT
      # guess one by stripping digits out of a run-together plate_number
      # (e.g. "ຍລ9143"), since that just re-displays the plate's own
      # letters as a fake type badge next to the number.
      parts  = raw_plate.split(/\s+/, 2)
      type   = parts.length > 1 ? parts[0] : ''
      number = parts.length > 1 ? parts[1] : raw_plate
    end

    pt = PlateType.for_code(type)
    if pt
      color_class   = pt.color_class
      show_province = vehicle.province.present? && pt.show_province
    else
      show_province = vehicle.province.present? && !NO_PROVINCE_TYPES.include?(type)
      color_class   = FALLBACK_COLOR_BY_TYPE.find { |types, _| types.include?(type) }&.last || 'plate-yellow'
    end

    # A real plate-type code is always short (1-4 Lao characters — see
    # every key in FALLBACK_COLOR_BY_TYPE above). Guard here regardless of
    # whether `pt` matched: a *matched* PlateType can still have a garbage
    # plate_code if someone fat-fingered the "ຈັດການປ້າຍ" admin form and
    # saved the long descriptive name into the plate_code field instead of
    # (or as well as) the name field — that record round-trips through
    # PlateType.for_code just fine and would otherwise still render the
    # long text next to the plate number.
    type = '' if type.length > 4

    PlateBadge.new(type, number, color_class, show_province)
  end
end
