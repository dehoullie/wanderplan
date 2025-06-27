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

ActiveRecord::Schema[7.1].define(version: 2025_06_25_090843) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.bigint "itinerary_id", null: false
    t.bigint "city_id", null: false
    t.integer "day"
    t.string "part_of_day"
    t.string "name"
    t.string "description"
    t.string "address"
    t.bigint "category_id", null: false
    t.string "map_url"
    t.integer "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_activities_on_category_id"
    t.index ["city_id"], name: "index_activities_on_city_id"
    t.index ["itinerary_id"], name: "index_activities_on_itinerary_id"
  end

  create_table "budgets", force: :cascade do |t|
    t.string "name"
    t.integer "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_preferences", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_categories_preferences_on_category_id"
    t.index ["preference_id"], name: "index_categories_preferences_on_preference_id"
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_cities_on_country_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "itineraries", force: :cascade do |t|
    t.bigint "preference_id", null: false
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["preference_id"], name: "index_itineraries_on_preference_id"
  end

  create_table "preferences", force: :cascade do |t|
    t.bigint "city_id", null: false
    t.bigint "budget_id", null: false
    t.integer "max_days"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_id"], name: "index_preferences_on_budget_id"
    t.index ["city_id"], name: "index_preferences_on_city_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "preference_id", null: false
    t.string "title"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["preference_id"], name: "index_users_preferences_on_preference_id"
    t.index ["user_id"], name: "index_users_preferences_on_user_id"
  end

  add_foreign_key "activities", "categories"
  add_foreign_key "activities", "cities"
  add_foreign_key "activities", "itineraries"
  add_foreign_key "categories_preferences", "categories"
  add_foreign_key "categories_preferences", "preferences"
  add_foreign_key "cities", "countries"
  add_foreign_key "itineraries", "preferences"
  add_foreign_key "preferences", "budgets"
  add_foreign_key "preferences", "cities"
  add_foreign_key "users_preferences", "preferences"
  add_foreign_key "users_preferences", "users"
end
