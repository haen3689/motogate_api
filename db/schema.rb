# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_07_022040) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.string "namespace"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "chat_messages", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "sender"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_chat_messages_on_user_id"
  end

  create_table "documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "document_type"
    t.string "file_url"
    t.string "name"
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id", null: false
    t.index ["vehicle_id"], name: "index_documents_on_vehicle_id"
  end

  create_table "inspection_centers", force: :cascade do |t|
    t.integer "capacity_per_day"
    t.datetime "created_at", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.text "location"
    t.string "logo"
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name"
    t.string "phone"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "inspection_services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "detail"
    t.integer "inspection_center_id"
    t.integer "max_cc"
    t.integer "min_cc"
    t.string "name"
    t.decimal "price"
    t.string "status"
    t.datetime "updated_at", null: false
    t.string "vehicle_type"
  end

  create_table "inspections", force: :cascade do |t|
    t.decimal "amount"
    t.datetime "appointment_at"
    t.string "center_address"
    t.string "center_name"
    t.datetime "created_at", null: false
    t.string "notes"
    t.string "service_name"
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id", null: false
    t.index ["vehicle_id"], name: "index_inspections_on_vehicle_id"
  end

  create_table "insurance_companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "email"
    t.string "logo"
    t.string "name"
    t.string "phone"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "insurance_packages", force: :cascade do |t|
    t.text "coverage"
    t.datetime "created_at", null: false
    t.integer "duration_months"
    t.integer "insurance_company_id"
    t.integer "max_cc"
    t.integer "max_seats"
    t.decimal "max_weight"
    t.integer "min_cc"
    t.integer "min_seats"
    t.decimal "min_weight"
    t.string "name"
    t.decimal "price"
    t.string "status"
    t.datetime "updated_at", null: false
    t.string "usage_type"
    t.string "vehicle_type"
  end

  create_table "insurances", force: :cascade do |t|
    t.decimal "amount"
    t.string "company"
    t.datetime "created_at", null: false
    t.date "end_date"
    t.string "package"
    t.date "start_date"
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id", null: false
    t.index ["vehicle_id"], name: "index_insurances_on_vehicle_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "notification_type"
    t.boolean "read"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "onboarding_slides", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "image_url"
    t.integer "position", default: 0, null: false
    t.text "subtitle", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plate_types", force: :cascade do |t|
    t.string "color_class", default: "plate-yellow", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "plate_code", null: false
    t.integer "position", default: 0, null: false
    t.boolean "show_province", default: true, null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
  end

  create_table "road_tax_rates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "max_cc"
    t.integer "max_seats"
    t.decimal "max_weight"
    t.integer "min_cc"
    t.integer "min_seats"
    t.decimal "min_weight"
    t.decimal "price"
    t.string "status"
    t.datetime "updated_at", null: false
    t.string "vehicle_type"
  end

  create_table "road_tax_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "fee_type"
    t.decimal "flat_amount"
    t.decimal "percent_rate"
    t.datetime "updated_at", null: false
  end

  create_table "road_taxes", force: :cascade do |t|
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.date "expired_at"
    t.date "paid_at"
    t.decimal "service_fee"
    t.string "source"
    t.string "status"
    t.integer "tax_year"
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id", null: false
    t.index ["vehicle_id"], name: "index_road_taxes_on_vehicle_id"
  end

  create_table "service_centers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "lat"
    t.decimal "lng"
    t.text "location"
    t.string "logo"
    t.string "name"
    t.string "owner_name"
    t.string "phone"
    t.decimal "rating"
    t.string "service_type"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.string "description"
    t.string "reference"
    t.string "status"
    t.string "transaction_type"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "district"
    t.string "fcm_token"
    t.string "first_name"
    t.string "gender"
    t.date "id_expiry_date"
    t.string "id_number"
    t.string "id_type", default: "national_id"
    t.string "last_name"
    t.date "license_expiry_date"
    t.string "license_number"
    t.string "license_type"
    t.string "name"
    t.string "otp"
    t.datetime "otp_expired_at"
    t.string "phone_number"
    t.string "platform", default: "android"
    t.string "province"
    t.datetime "updated_at", null: false
    t.boolean "verified"
    t.string "village"
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
  end

  create_table "vehicle_brands", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "axle_count"
    t.string "brand"
    t.string "cc"
    t.string "chassis_number"
    t.string "color"
    t.datetime "created_at", null: false
    t.string "cylinder_count"
    t.string "engine_number"
    t.boolean "fee_paid", default: false, null: false
    t.string "fuel_type"
    t.string "model"
    t.string "owner_name"
    t.string "plate_number"
    t.string "plate_type"
    t.string "province"
    t.date "registration_expiry_date"
    t.string "seat_count"
    t.datetime "updated_at", null: false
    t.string "usage_type"
    t.bigint "user_id", null: false
    t.string "vehicle_type"
    t.string "weight"
    t.integer "year"
    t.index ["user_id"], name: "index_vehicles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chat_messages", "users"
  add_foreign_key "documents", "vehicles"
  add_foreign_key "inspections", "vehicles"
  add_foreign_key "insurances", "vehicles"
  add_foreign_key "notifications", "users"
  add_foreign_key "road_taxes", "vehicles"
  add_foreign_key "transactions", "users"
  add_foreign_key "vehicles", "users"
end
