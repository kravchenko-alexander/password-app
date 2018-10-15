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

ActiveRecord::Schema.define(version: 2018_10_14_132545) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "password_sets", force: :cascade do |t|
    t.string "access_token"
    t.boolean "decrypted", default: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_password_sets_on_user_id"
  end

  create_table "password_views", force: :cascade do |t|
    t.string "status"
    t.string "ip"
    t.bigint "password_set_id"
    t.integer "viewer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["password_set_id"], name: "index_password_views_on_password_set_id"
  end

  create_table "passwords", force: :cascade do |t|
    t.string "encrypted_password"
    t.bigint "password_set_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["password_set_id"], name: "index_passwords_on_password_set_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "device"
    t.string "access_token"
    t.string "refresh_token"
    t.string "push_token"
    t.datetime "access_token_expired_at"
    t.datetime "refresh_token_expired_at"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "password_sets", "users"
  add_foreign_key "password_views", "password_sets"
  add_foreign_key "passwords", "password_sets"
  add_foreign_key "sessions", "users"
end
