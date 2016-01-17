# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160117103218) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "gundams", force: :cascade do |t|
    t.integer  "carousell_id"
    t.string   "title"
    t.string   "price"
    t.text     "description"
    t.string   "location_address"
    t.string   "location_name"
    t.datetime "time_created"
  end

  create_table "notified_gundams", force: :cascade do |t|
    t.integer "carousell_id"
  end

  create_table "tags", force: :cascade do |t|
    t.integer "watchlist_id"
    t.string  "tag"
  end

  add_index "tags", ["watchlist_id"], name: "index_tags_on_watchlist_id", using: :btree

  create_table "watchlists", force: :cascade do |t|
    t.string   "chat_id"
    t.datetime "last_notified"
  end

  add_foreign_key "tags", "watchlists"
end
