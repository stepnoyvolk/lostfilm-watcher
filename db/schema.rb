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

ActiveRecord::Schema.define(version: 20171216022616) do

  create_table "serials", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "image"
    t.string "serial_link"
    t.text "about_short"
    t.text "about_full"
    t.boolean "tracked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "magnet"
    t.text "filename"
  end

  create_table "series", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "serial_id"
    t.string "serial_name"
    t.text "serie_name"
    t.text "magnet"
    t.integer "season"
    t.integer "serie"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "downloaded"
    t.text "filename"
    t.boolean "sms"
    t.string "torrnetid"
    t.string "torrent_status"
    t.string "download_status"
    t.index ["serial_id"], name: "index_series_on_serial_id"
  end

end
