module PlateBadgeHelper
  PlateBadge = Struct.new(:number, :color_class, :province)

  # Resolves a vehicle's badge color/province display — shared between the
  # vehicles list and any other admin page that renders the same plate
  # badge (e.g. inspections/bookings), so the lookup only lives in one
  # place.
  #
  # plate_number is shown exactly as typed, in full. It is NOT parsed for
  # a "type" prefix and never has anything stripped from or appended to
  # it — a real plate can start with any of many letter combinations
  # (ກກ, ກຂ, ກຄ, ກຈ, ກຊ, ...), and there's no fixed, closed set of prefixes
  # to match against. vehicle.plate_type only serves as the lookup key for
  # which "ຈັດການປ້າຍທະບຽນ" row's color_class/show_province applies — it is
  # never itself rendered on the badge.
  def plate_badge_for(vehicle)
    pt = vehicle.plate_type.present? ? PlateType.for_code(vehicle.plate_type) : nil

    color_class   = pt&.color_class || 'plate-yellow'
    show_province = pt&.show_province && vehicle.province.present?
    province      = show_province ? vehicle.province.to_s.strip.presence : nil

    PlateBadge.new(vehicle.plate_number.to_s.strip, color_class, province)
  end
end
