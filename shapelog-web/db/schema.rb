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

ActiveRecord::Schema[8.1].define(version: 2026_04_15_021550) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "body_measurements", force: :cascade do |t|
    t.decimal "arm", precision: 5, scale: 2
    t.decimal "chest", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.text "notes"
    t.decimal "thigh", precision: 5, scale: 2
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "waist", precision: 5, scale: 2
    t.index ["user_id", "date"], name: "index_body_measurements_on_user_id_and_date"
    t.index ["user_id"], name: "index_body_measurements_on_user_id"
  end

  create_table "daily_checkins", force: :cascade do |t|
    t.integer "calories_estimate"
    t.boolean "cardio", default: false, null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "energy_level"
    t.integer "hunger_level"
    t.text "notes"
    t.integer "steps"
    t.boolean "trained", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "waist", precision: 5, scale: 2
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

  create_table "mounjaro_applications", force: :cascade do |t|
    t.date "application_date", null: false
    t.string "application_site"
    t.datetime "created_at", null: false
    t.decimal "dose", precision: 4, scale: 2, null: false
    t.text "notes"
    t.text "side_effects"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "application_date"], name: "index_mounjaro_applications_on_user_id_and_application_date"
    t.index ["user_id"], name: "index_mounjaro_applications_on_user_id"
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

  add_foreign_key "body_measurements", "users"
  add_foreign_key "daily_checkins", "users"
  add_foreign_key "goals", "users"
  add_foreign_key "mounjaro_applications", "users"
  add_foreign_key "sessions", "users"
end
