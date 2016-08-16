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

ActiveRecord::Schema.define(version: 20160731065255) do

  create_table "books", force: :cascade do |t|
    t.string   "title"
    t.string   "asin"
    t.string   "jd_id"
    t.string   "author"
    t.string   "publisher"
    t.string   "image"
    t.decimal  "price",        precision: 10, scale: 2
    t.text     "origin_url"
    t.text     "purchase_url"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "books_carts", id: false, force: :cascade do |t|
    t.integer "book_id", null: false
    t.integer "cart_id", null: false
    t.index ["book_id"], name: "index_books_carts_on_book_id"
    t.index ["cart_id"], name: "index_books_carts_on_cart_id"
  end

  create_table "carts", force: :cascade do |t|
    t.integer  "vote_session_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["vote_session_id"], name: "index_carts_on_vote_session_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vote_sessions", force: :cascade do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.decimal  "budget",     precision: 10, scale: 2
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "book_id"
    t.integer  "vote_session_id"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["book_id"], name: "index_votes_on_book_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
    t.index ["vote_session_id"], name: "index_votes_on_vote_session_id"
  end

end
