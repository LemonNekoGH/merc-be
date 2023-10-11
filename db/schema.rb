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

ActiveRecord::Schema[7.0].define(version: 2023_09_30_081633) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chat_requests", force: :cascade do |t|
    t.string "from_address", null: false
    t.string "to_address", null: false
    t.boolean "accepted"
    t.boolean "canceled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chats", force: :cascade do |t|
    t.string "from_address", null: false
    t.string "to_address", null: false
    t.string "end_by"
    t.datetime "end_at"
    t.integer "from_response"
    t.string "from_response_reason"
    t.integer "to_response"
    t.string "to_response_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "message_to_halls", force: :cascade do |t|
    t.string "message", null: false
    t.datetime "created_at", null: false
  end

  create_table "message_to_users", force: :cascade do |t|
    t.integer "chat_id", null: false
    t.string "message", null: false
    t.string "from", null: false
    t.datetime "created_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "address", null: false
    t.string "nickname"
    t.string "gender"
    t.string "avatar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["address"], name: "index_users_on_address", unique: true
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
  end

end
