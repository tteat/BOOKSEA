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

ActiveRecord::Schema.define(version: 20171216114657) do

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exchanges", force: :cascade do |t|
    t.boolean "is_active"
    t.integer "book_initier_id"
    t.integer "book_receiver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.index ["book_initier_id"], name: "index_exchanges_on_book_initier_id"
    t.index ["book_receiver_id"], name: "index_exchanges_on_book_receiver_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "first_name"
    t.date "birthday"
    t.boolean "is_male"
    t.string "description"
    t.integer "category_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "disabled", default: false
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.index ["category_id"], name: "index_books_on_category_id"
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "tag_relations", force: :cascade do |t|
    t.integer "exchange_id"
    t.integer "tag_id"
    t.integer "book_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exchange_id"], name: "index_tag_relations_on_exchange_id"
    t.index ["book_id"], name: "index_tag_relations_on_book_id"
    t.index ["tag_id"], name: "index_tag_relations_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "label_male"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label_female"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "phone"
    t.boolean "is_admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.string "title"
    t.string "content"
    t.string "place"
    t.datetime "starttime",null:false
    t.datetime "created_at", null: false
    t.datetime "finishtime",null:false
    t.datetime "ended_at", null: false
    t.integer "user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "content"
    t.integer "book_id"
    t.datetime "created_at", null: false
    t.integer "user_id"
  end

end
