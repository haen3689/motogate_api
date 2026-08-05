ActiveAdmin.register User do
  menu priority: 2
  config.batch_actions = false

  permit_params :phone_number, :name, :first_name, :last_name, :gender,
                :date_of_birth, :province, :district, :village,
                :id_type, :id_number, :id_expiry_date,
                :license_number, :license_type, :license_expiry_date, :verified,
                :profile_image, :id_card_image, :license_image

  config.filters = false

  # =========================================
  # INDEX — custom partial (Bootstrap 5)
  # =========================================
  index title: false, download_links: false do
    render partial: "active_admin/users_content"
  end

  # =========================================
  # SHOW — custom partial (Bootstrap 5)
  # =========================================
  show do
    render partial: "active_admin/user_show_content", locals: { user: user }
  end

  # =========================================
  # FORM — custom partial (Bootstrap 5)
  # =========================================
  form multipart: true do |f|
    render partial: "active_admin/user_form_content", locals: { f: f }
  end
end
