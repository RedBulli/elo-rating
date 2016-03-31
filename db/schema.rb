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

ActiveRecord::Schema.define(version: 20160331181203) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "elos", force: :cascade do |t|
    t.integer "player_id",                           null: false
    t.decimal "rating",      precision: 6, scale: 2, null: false
    t.integer "frame_id"
    t.boolean "winner"
    t.boolean "breaker"
    t.boolean "provisional",                         null: false
  end

  create_table "frames", force: :cascade do |t|
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "game_type",  default: "eight_ball", null: false
    t.index ["created_at"], name: "index_frames_on_created_at", using: :btree
  end

  create_table "players", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "elo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "elos_count"
  end

  add_foreign_key "elos", "frames"
  add_foreign_key "elos", "players"
  add_foreign_key "players", "elos"
end
