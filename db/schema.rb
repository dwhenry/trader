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

ActiveRecord::Schema.define(version: 20170102145815) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "businesses", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "custom_configs", force: :cascade do |t|
    t.string   "object_type"
    t.string   "object_id"
    t.jsonb    "config"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "portfolios", force: :cascade do |t|
    t.integer  "business_id"
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["business_id"], name: "index_portfolios_on_business_id", using: :btree
  end

  create_table "securities", force: :cascade do |t|
    t.string   "name"
    t.string   "ticker"
    t.string   "currency"
    t.jsonb    "custom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trades", force: :cascade do |t|
    t.integer  "quantity"
    t.decimal  "price"
    t.string   "currency"
    t.date     "date"
    t.integer  "security_id"
    t.integer  "portfolio_id"
    t.jsonb    "custom"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["portfolio_id"], name: "index_trades_on_portfolio_id", using: :btree
    t.index ["security_id"], name: "index_trades_on_security_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.integer  "business_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "email"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["business_id"], name: "index_users_on_business_id", using: :btree
  end

  add_foreign_key "portfolios", "businesses"
  add_foreign_key "trades", "portfolios"
  add_foreign_key "trades", "securities"
  add_foreign_key "users", "businesses"
end
