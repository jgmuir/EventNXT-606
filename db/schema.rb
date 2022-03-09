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

ActiveRecord::Schema.define(version: 2022_03_08_001540) do

  # These are extensions that must be enabled in order to support this database
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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.string "date"
    t.integer "total_seats"
    t.string "box_office_customers"
    t.integer "total_seats_box_office"
    t.integer "total_seats_guest"
    t.integer "balance"
  end

  create_table "guest_referral_rewards", force: :cascade do |t|
    t.bigint "guests_id", null: false
    t.bigint "referral_rewards_id", null: false
    t.integer "count", default: 0
    t.index ["guests_id"], name: "index_guest_referral_rewards_on_guests_id"
    t.index ["referral_rewards_id"], name: "index_guest_referral_rewards_on_referral_rewards_id"
  end

  create_table "guest_seat_tickets", force: :cascade do |t|
    t.bigint "guests_id", null: false
    t.bigint "seats_id", null: false
    t.integer "committed"
    t.integer "allotted"
    t.index ["guests_id"], name: "index_guest_seat_tickets_on_guests_id"
    t.index ["seats_id"], name: "index_guest_seat_tickets_on_seats_id"
  end

  create_table "guests", force: :cascade do |t|
    t.bigint "events_id", null: false
    t.bigint "added_by", null: false
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "affiliation"
    t.string "type"
    t.boolean "booked", default: false, null: false
    t.datetime "invite_expiration"
    t.datetime "referral_expiration"
    t.datetime "invited_at"
    t.index ["added_by"], name: "index_guests_on_added_by"
    t.index ["email"], name: "index_guests_on_email", unique: true
    t.index ["events_id"], name: "index_guests_on_events_id"
  end

  create_table "referral_rewards", force: :cascade do |t|
    t.bigint "events_id", null: false
    t.string "reward"
    t.integer "min_count", default: 0
    t.index ["events_id"], name: "index_referral_rewards_on_events_id"
  end

  create_table "seat_category_details", force: :cascade do |t|
    t.string "event_title"
    t.string "seat_category"
    t.integer "total_seats"
    t.integer "vip_seats"
    t.integer "non_vip_seats"
    t.integer "balance"
  end

  create_table "seats", force: :cascade do |t|
    t.bigint "events_id", null: false
    t.string "category", null: false
    t.integer "total_count"
    t.float "price"
    t.index ["events_id"], name: "index_seats_on_events_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "events_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["events_id"], name: "index_users_on_events_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "guest_referral_rewards", "guests", column: "guests_id"
  add_foreign_key "guest_referral_rewards", "referral_rewards", column: "referral_rewards_id"
  add_foreign_key "guest_seat_tickets", "guests", column: "guests_id"
  add_foreign_key "guest_seat_tickets", "seats", column: "seats_id"
  add_foreign_key "guests", "events", column: "events_id"
  add_foreign_key "guests", "users", column: "added_by"
  add_foreign_key "referral_rewards", "events", column: "events_id"
  add_foreign_key "seats", "events", column: "events_id"
  add_foreign_key "users", "events", column: "events_id"
end
