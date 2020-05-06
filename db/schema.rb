# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_17_203455) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "cube"
  enable_extension "earthdistance"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.string "addressable_type"
    t.integer "addressable_id"
    t.string "category", limit: 64
    t.string "full_name"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state_code"
    t.string "country_code"
    t.string "postal_code"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["addressable_id"], name: "index_addresses_on_addressable_id"
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id"
  end

  create_table "admin_push_notification_tokens", force: :cascade do |t|
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_rights", id: false, force: :cascade do |t|
    t.string "subject_type"
    t.bigint "subject_id"
    t.integer "admin_id"
    t.index ["admin_id"], name: "index_admin_rights_on_admin_id"
    t.index ["subject_type", "subject_id"], name: "index_admin_rights_on_subject_type_and_subject_id"
  end

  create_table "admin_tokens", force: :cascade do |t|
    t.string "value", null: false
    t.datetime "expired_at", null: false
    t.integer "admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "admin_push_notification_token_id"
    t.index ["admin_id"], name: "index_admin_tokens_on_admin_id"
    t.index ["admin_push_notification_token_id"], name: "index_admin_tokens_on_admin_push_notification_token_id"
    t.index ["value"], name: "index_admin_tokens_on_value"
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", default: "", null: false
    t.string "phone"
    t.string "avatar"
    t.string "name"
    t.integer "status", default: 0
    t.bigint "role_id"
    t.string "trackers", default: [], array: true
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_admins_on_role_id"
    t.index ["username"], name: "index_admins_on_username", unique: true
  end

  create_table "agencies", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.integer "status", default: 0
    t.string "avatar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
  end

  create_table "ai_tokens", force: :cascade do |t|
    t.string "value"
    t.string "name"
    t.datetime "last_use"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["value"], name: "index_ai_tokens_on_value"
  end

  create_table "alerts", force: :cascade do |t|
    t.integer "type", default: 0
    t.string "subject_type"
    t.bigint "subject_id"
    t.integer "status", default: 0
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_type", "subject_id"], name: "index_alerts_on_subject_type_and_subject_id"
    t.index ["user_id"], name: "index_alerts_on_user_id"
  end

  create_table "bills_payment_transactions", id: false, force: :cascade do |t|
    t.bigint "bill_id", null: false
    t.bigint "payment_transaction_id", null: false
    t.index ["bill_id"], name: "index_bills_payment_transactions_on_bill_id"
    t.index ["payment_transaction_id"], name: "index_bills_payment_transactions_on_payment_transaction_id"
  end

  create_table "cameras", force: :cascade do |t|
    t.string "stream"
    t.string "login"
    t.string "name"
    t.string "password"
    t.bigint "parking_lot_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "vmarkup"
    t.string "other_information"
    t.boolean "allowed", default: true
    t.index ["parking_lot_id"], name: "index_cameras_on_parking_lot_id"
  end

  create_table "coordinate_parking_plans", force: :cascade do |t|
    t.float "x"
    t.float "y"
    t.bigint "parking_slot_id"
    t.bigint "image_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["image_id"], name: "index_coordinate_parking_plans_on_image_id"
    t.index ["parking_slot_id"], name: "index_coordinate_parking_plans_on_parking_slot_id"
  end

  create_table "credit_cards", force: :cascade do |t|
    t.bigint "user_id"
    t.string "holder_name"
    t.string "number"
    t.integer "expiration_month"
    t.integer "expiration_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "network"
    t.index ["user_id"], name: "index_credit_cards_on_user_id"
  end

  create_table "disputes", force: :cascade do |t|
    t.bigint "parking_session_id"
    t.bigint "user_id"
    t.bigint "admin_id"
    t.integer "status", default: 0
    t.integer "reason", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_disputes_on_admin_id"
    t.index ["parking_session_id"], name: "index_disputes_on_parking_session_id"
    t.index ["user_id"], name: "index_disputes_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "file"
    t.string "imageable_type"
    t.bigint "imageable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "meta_name"
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id"
  end

  create_table "kiosks", force: :cascade do |t|
    t.bigint "parking_lot_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parking_lot_id"], name: "index_kiosks_on_parking_lot_id"
  end

  create_table "ksk_tokens", force: :cascade do |t|
    t.string "value"
    t.string "name"
    t.bigint "kiosk_id"
    t.datetime "last_use"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kiosk_id"], name: "index_ksk_tokens_on_kiosk_id"
    t.index ["value"], name: "index_ksk_tokens_on_value"
  end

  create_table "locations", force: :cascade do |t|
    t.string "zip"
    t.string "building"
    t.string "street"
    t.string "city"
    t.string "country"
    t.float "ltd"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subject_type"
    t.bigint "subject_id"
    t.string "full_address"
    t.string "state"
    t.index ["subject_type", "subject_id"], name: "index_locations_on_subject_type_and_subject_id"
  end

  create_table "manufacturers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string "subject_type"
    t.bigint "subject_id"
    t.text "text"
    t.string "author_type"
    t.bigint "author_id"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "to_type"
    t.bigint "to_id"
    t.integer "template"
    t.string "title"
    t.bigint "parking_session_id"
    t.index ["author_type", "author_id"], name: "index_messages_on_author_type_and_author_id"
    t.index ["parking_session_id"], name: "index_messages_on_parking_session_id"
    t.index ["subject_type", "subject_id"], name: "index_messages_on_subject_type_and_subject_id"
    t.index ["to_type", "to_id"], name: "index_messages_on_to_type_and_to_id"
  end

  create_table "parking_lots", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "name"
    t.string "phone"
    t.string "avatar"
    t.integer "status", default: 0
    t.json "outline"
    t.string "time_zone", default: "Eastern Time (US & Canada)"
  end

  create_table "parking_recipients", force: :cascade do |t|
    t.bigint "rule_id"
    t.bigint "admin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_parking_recipients_on_admin_id"
    t.index ["rule_id"], name: "index_parking_recipients_on_rule_id"
  end

  create_table "parking_rules", force: :cascade do |t|
    t.integer "name", default: 0
    t.text "description"
    t.boolean "status", default: false
    t.bigint "agency_id"
    t.bigint "lot_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_parking_rules_on_agency_id"
    t.index ["lot_id"], name: "index_parking_rules_on_lot_id"
  end

  create_table "parking_sessions", force: :cascade do |t|
    t.datetime "check_in"
    t.datetime "check_out"
    t.bigint "parking_slot_id"
    t.bigint "vehicle_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.integer "parking_lot_id"
    t.datetime "parked_at"
    t.datetime "left_at"
    t.string "uuid"
    t.datetime "entered_at"
    t.datetime "exit_at"
    t.integer "ai_status", default: 0
    t.float "fee_applied"
    t.bigint "kiosk_id"
    t.index ["kiosk_id"], name: "index_parking_sessions_on_kiosk_id"
    t.index ["parking_slot_id"], name: "index_parking_sessions_on_parking_slot_id"
    t.index ["vehicle_id"], name: "index_parking_sessions_on_vehicle_id"
  end

  create_table "parking_settings", force: :cascade do |t|
    t.float "rate"
    t.integer "parked"
    t.integer "overtime"
    t.integer "period"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "free", default: 0
    t.string "subject_type"
    t.bigint "subject_id"
    t.index ["subject_type", "subject_id"], name: "index_parking_settings_on_subject_type_and_subject_id"
  end

  create_table "parking_slots", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parking_zone_id"
    t.integer "status", default: 0
    t.integer "parking_lot_id"
    t.boolean "archived", default: false
    t.bigint "zone_id"
    t.index ["name", "parking_lot_id"], name: "index_parking_slots_on_name_and_parking_lot_id", unique: true
    t.index ["parking_zone_id"], name: "index_parking_slots_on_parking_zone_id"
    t.index ["zone_id"], name: "index_parking_slots_on_zone_id"
  end

  create_table "parking_tickets", force: :cascade do |t|
    t.bigint "admin_id"
    t.bigint "agency_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "violation_id"
    t.string "photo_resolution"
    t.index ["admin_id"], name: "index_parking_tickets_on_admin_id"
    t.index ["agency_id"], name: "index_parking_tickets_on_agency_id"
    t.index ["violation_id"], name: "index_parking_tickets_on_violation_id"
  end

  create_table "parking_vehicle_rules", force: :cascade do |t|
    t.string "color"
    t.bigint "vehicle_id"
    t.string "vehicle_type"
    t.integer "status", default: 0
    t.bigint "lot_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lot_id"], name: "index_parking_vehicle_rules_on_lot_id"
    t.index ["vehicle_id"], name: "index_parking_vehicle_rules_on_vehicle_id"
  end

  create_table "parking_violations", force: :cascade do |t|
    t.string "description"
    t.datetime "fixed_at"
    t.bigint "rule_id"
    t.bigint "session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parking_vehicle_rules_id"
    t.index ["parking_vehicle_rules_id"], name: "index_parking_violations_on_parking_vehicle_rules_id"
    t.index ["rule_id"], name: "index_parking_violations_on_rule_id"
    t.index ["session_id"], name: "index_parking_violations_on_session_id"
  end

  create_table "parking_zones", force: :cascade do |t|
    t.string "name"
    t.bigint "lot_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lot_id"], name: "index_parking_zones_on_lot_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount"
    t.bigint "parking_session_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "payment_method"
    t.string "payment_gateway"
    t.json "meta_data"
    t.string "card_last_four_digits"
    t.index ["parking_session_id"], name: "index_payments_on_parking_session_id"
  end

  create_table "places", force: :cascade do |t|
    t.bigint "parking_lot_id"
    t.string "name"
    t.integer "category"
    t.float "distance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parking_lot_id"], name: "index_places_on_parking_lot_id"
  end

  create_table "reports", force: :cascade do |t|
    t.string "name"
    t.string "type_type"
    t.bigint "type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type_type", "type_id"], name: "index_reports_on_type_type_and_type_id"
  end

  create_table "role_permission_attributes", force: :cascade do |t|
    t.bigint "permission_id"
    t.string "name"
    t.boolean "attr_read", default: false
    t.boolean "attr_update", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "permission_id"], name: "index_role_permission_attributes_on_name_and_permission_id", unique: true
    t.index ["permission_id"], name: "index_role_permission_attributes_on_permission_id"
  end

  create_table "role_permissions", force: :cascade do |t|
    t.bigint "role_id"
    t.string "name"
    t.boolean "record_create", default: false
    t.boolean "record_read", default: false
    t.boolean "record_update", default: false
    t.boolean "record_delete", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "role_id"], name: "index_role_permissions_on_name_and_role_id", unique: true
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.boolean "full", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "user_notifications", force: :cascade do |t|
    t.integer "template"
    t.bigint "user_id"
    t.string "title"
    t.text "text"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parking_session_id"
    t.index ["parking_session_id"], name: "index_user_notifications_on_parking_session_id"
    t.index ["user_id"], name: "index_user_notifications_on_user_id"
  end

  create_table "user_push_notification_tokens", force: :cascade do |t|
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_tokens", force: :cascade do |t|
    t.string "value", null: false
    t.datetime "expired_at", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_push_notification_token_id"
    t.index ["user_id"], name: "index_user_tokens_on_user_id"
    t.index ["user_push_notification_token_id"], name: "index_user_tokens_on_user_push_notification_token_id"
    t.index ["value"], name: "index_user_tokens_on_value"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.citext "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "birthday"
    t.string "avatar"
    t.integer "default_credit_card_id"
    t.string "trackers", default: [], array: true
    t.boolean "is_dev", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["default_credit_card_id"], name: "index_users_on_default_credit_card_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.citext "plate_number"
    t.string "vehicle_type"
    t.string "color"
    t.string "model"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "status", default: 0
    t.bigint "manufacturer_id"
    t.index ["manufacturer_id"], name: "index_vehicles_on_manufacturer_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.text "comment"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "admin_tokens", "admin_push_notification_tokens"
  add_foreign_key "admins", "roles"
  add_foreign_key "alerts", "users"
  add_foreign_key "cameras", "parking_lots"
  add_foreign_key "coordinate_parking_plans", "images"
  add_foreign_key "coordinate_parking_plans", "parking_slots"
  add_foreign_key "disputes", "parking_sessions"
  add_foreign_key "ksk_tokens", "kiosks"
  add_foreign_key "messages", "parking_sessions"
  add_foreign_key "parking_recipients", "admins"
  add_foreign_key "parking_recipients", "parking_rules", column: "rule_id"
  add_foreign_key "parking_rules", "agencies"
  add_foreign_key "parking_rules", "parking_lots", column: "lot_id"
  add_foreign_key "parking_sessions", "kiosks"
  add_foreign_key "parking_slots", "parking_zones", column: "zone_id"
  add_foreign_key "parking_tickets", "admins"
  add_foreign_key "parking_tickets", "agencies"
  add_foreign_key "parking_tickets", "parking_violations", column: "violation_id"
  add_foreign_key "parking_vehicle_rules", "parking_lots", column: "lot_id"
  add_foreign_key "parking_vehicle_rules", "vehicles"
  add_foreign_key "parking_violations", "parking_rules", column: "rule_id"
  add_foreign_key "parking_violations", "parking_sessions", column: "session_id"
  add_foreign_key "parking_violations", "parking_vehicle_rules", column: "parking_vehicle_rules_id"
  add_foreign_key "parking_zones", "parking_lots", column: "lot_id"
  add_foreign_key "places", "parking_lots"
  add_foreign_key "role_permission_attributes", "role_permissions", column: "permission_id"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "user_notifications", "parking_sessions"
  add_foreign_key "user_tokens", "user_push_notification_tokens"
  add_foreign_key "vehicles", "manufacturers"
end
