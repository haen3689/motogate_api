ActiveAdmin.register Vehicle do
  menu priority: 3, if: -> { !current_admin_user.partner? }
  config.batch_actions = false
  config.filters = false

  permit_params :user_id, :plate_number, :plate_type, :brand, :model, :year, :color, :vehicle_type,
                :engine_number, :chassis_number, :cc, :province, :usage_type,
                :owner_name, :fuel_type, :seat_count, :axle_count, :cylinder_count, :weight,
                :registration_expiry_date,
                :registration_front, :registration_back, :front_photo, :transport_booklet

  index title: false, download_links: false do
    render partial: "active_admin/vehicles_content"
  end

  show do
    render partial: "active_admin/vehicle_show_content", locals: { vehicle: vehicle }
  end

  form partial: "active_admin/vehicle_form_content"

  # TEMPORARY — diagnosing a 500 on edit/update. Safe because it only fires
  # for requests that already passed admin authentication. Remove once fixed.
  controller do
    rescue_from StandardError do |e|
      render plain: "#{e.class}: #{e.message}\n\n#{e.backtrace.first(30).join("\n")}", status: 500
    end
  end

  # "ຜູ້ໃຊ້ຮອງ" (sub_owner_phone) isn't a Vehicle column — it grants an
  # already-registered user read-only access via the same VehicleShare
  # mechanism the app's "ຜູ້ໃຊ້ສຳຮອງ" feature uses.
  after_save do |vehicle|
    phone = params.dig(:vehicle, :sub_owner_phone).to_s.strip
    next if phone.blank?

    target = User.find_by(phone_number: phone)
    next unless target && target.id != vehicle.user_id

    vehicle.vehicle_shares.find_or_create_by(user: target)
  end
end
