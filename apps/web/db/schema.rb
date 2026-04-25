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

ActiveRecord::Schema[8.1].define(version: 2026_04_23_033231) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "alerts", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "channel", null: false
    t.datetime "created_at", null: false
    t.time "dispatch_time", null: false
    t.integer "dispatch_weekday"
    t.integer "periodicity", null: false
    t.string "phone_number"
    t.text "recipients", default: [], array: true
    t.integer "report_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "channel"], name: "index_alerts_on_user_id_and_channel"
    t.index ["user_id"], name: "index_alerts_on_user_id"
  end

  create_table "daily_checkins", force: :cascade do |t|
    t.boolean "anxiolytic_used", default: false, null: false
    t.boolean "cardio", default: false, null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "energy_level"
    t.integer "hunger_level"
    t.integer "mood_stress_level"
    t.text "notes"
    t.boolean "trained", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "weight", precision: 5, scale: 2, null: false
    t.index ["user_id", "date"], name: "index_daily_checkins_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_daily_checkins_on_user_id"
  end

  create_table "goals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "start_date", null: false
    t.decimal "starting_weight", precision: 5, scale: 2, null: false
    t.decimal "target_weight", precision: 5, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "weekly_target", precision: 4, scale: 2
    t.index ["user_id"], name: "index_goals_on_user_id", unique: true
  end

  create_table "medication_options", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_used_at"
    t.string "name", null: false
    t.string "normalized_name", null: false
    t.datetime "updated_at", null: false
    t.integer "usage_count", default: 0, null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "normalized_name"], name: "index_medication_options_on_user_id_and_normalized_name", unique: true
    t.index ["user_id"], name: "index_medication_options_on_user_id"
  end

  create_table "medications", force: :cascade do |t|
    t.string "administration_site"
    t.datetime "created_at", null: false
    t.decimal "dosage", precision: 5, scale: 2, null: false
    t.string "dosage_unit", null: false
    t.bigint "medication_option_id", null: false
    t.text "notes"
    t.text "side_effects"
    t.datetime "taken_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["medication_option_id"], name: "index_medications_on_medication_option_id"
    t.index ["user_id", "taken_at"], name: "index_medications_on_user_id_and_taken_at"
    t.index ["user_id"], name: "index_medications_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "alerts", "users"
  add_foreign_key "daily_checkins", "users"
  add_foreign_key "goals", "users"
  add_foreign_key "medication_options", "users"
  add_foreign_key "medications", "medication_options"
  add_foreign_key "medications", "users"
  add_foreign_key "sessions", "users"
end
