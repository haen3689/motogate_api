module PlateBadgeHelper
  PlateBadge = Struct.new(:type, :number, :color_class, :province)

  NO_PROVINCE_TYPES = %w[].freeze

  FALLBACK_COLOR_BY_TYPE = {
    %w[] => 'plate-yellow',
    %w[] => 'plate-yellow-green',
    %w[] => 'plate-blue',
    %w[] => 'plate-white',
    %w[] => 'plate-yellow-blue',
    %w[] => 'plate-white-darkblue',
    %w[] => 'plate-white-lightblue',
    %w[] => 'plate-red-underline',
    %w[] => 'plate-red',
    %w[] => 'plate-white-1percent',
    %w[] => 'plate-diplomat',
  }.freeze

  # Splits a vehicle's plate_number/plate_type into badge-ready parts and
  # resolves its display color — shared between the vehicles list and any
  # other admin page that needs to render the same plate badge (e.g. the
  # inspections/bookings list), so the parsing rules only live in one place.
  def plate_badge_for(vehicle)
    raw_plate = vehicle.plate_number.to_s.strip

    if vehicle.plate_type.present?
      type = vehicle.plate_type.to_s.strip
      # plate_number sometimes already includes the type prefix (e.g. "ກດ1234"
      # when plate_type is "ກດ") — strip it so the badge doesn't show it
      # twice. `+` (not just one match) also covers plate_number somehow
      # having the type typed more than once ("ກກ ກກ 1234"), which would
      # otherwise only get the first occurrence stripped and still show
      # the type code duplicated next to the number.
      number = type.present? ? raw_plate.sub(/\A(?:#{Regexp.escape(type)}\s*)+/, '').strip : raw_plate
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

    # Only surface the province line when it actually says something the
    # type badge doesn't already say. Reported bug: a vehicle's province
    # ended up holding the same short value as its plate type (e.g. both
    # "ກກ"), so the badge rendered "ກກ ກກ 1234" — the type line and the
    # province line showing the identical text right on top of each other.
    province = vehicle.province.to_s.strip
    province = nil if province.blank? || !show_province || province == type

    PlateBadge.new(type, number, color_class, province)
  end
end
