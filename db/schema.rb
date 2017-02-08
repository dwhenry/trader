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

ActiveRecord::Schema.define(version: 20170208232430) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "backoffices", force: :cascade do |t|
    t.string   "trade_uid",                      null: false
    t.integer  "trade_version",                  null: false
    t.string   "state",                          null: false
    t.date     "settlement_date"
    t.integer  "version",         default: 1,    null: false
    t.boolean  "current",         default: true, null: false
    t.jsonb    "custom"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["trade_uid"], name: "index_backoffices_on_trade_uid", using: :btree
    t.index ["trade_version"], name: "index_backoffices_on_trade_version", using: :btree
  end

  create_table "businesses", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "custom_configs", force: :cascade do |t|
    t.string   "owner_type"
    t.string   "owner_id"
    t.jsonb    "config"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "config_type"
  end

  create_table "events", force: :cascade do |t|
    t.integer  "business_id"
    t.integer  "user_id"
    t.string   "event_type"
    t.jsonb    "details"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "owner_type",    null: false
    t.integer  "parent_id"
    t.integer  "owner_id"
    t.string   "trade_uid"
    t.string   "portfolio_uid"
    t.index ["business_id"], name: "index_events_on_business_id", using: :btree
    t.index ["user_id"], name: "index_events_on_user_id", using: :btree
  end

  create_table "permissions", force: :cascade do |t|
    t.string   "name"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_permissions_on_role_id", using: :btree
  end

  create_table "portfolios", force: :cascade do |t|
    t.integer  "business_id"
    t.string   "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "uid",                        null: false
    t.integer  "version",     default: 1,    null: false
    t.boolean  "current",     default: true, null: false
    t.index ["business_id"], name: "index_portfolios_on_business_id", using: :btree
  end

  create_table "prices", force: :cascade do |t|
    t.string   "ticker"
    t.date     "date"
    t.decimal  "open"
    t.decimal  "close"
    t.decimal  "high"
    t.decimal  "low"
    t.integer  "volume"
    t.decimal  "adj_close"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_prices_on_date", using: :btree
    t.index ["ticker"], name: "index_prices_on_ticker", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "business_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["business_id"], name: "index_roles_on_business_id", using: :btree
  end

  create_table "securities", force: :cascade do |t|
    t.string   "name"
    t.string   "ticker"
    t.string   "currency"
    t.jsonb    "custom"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "track",       default: true, null: false
    t.integer  "business_id",                null: false
  end

  create_table "trades", force: :cascade do |t|
    t.integer  "quantity"
    t.decimal  "price"
    t.string   "currency"
    t.date     "date"
    t.integer  "security_id"
    t.integer  "portfolio_id"
    t.jsonb    "custom"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "version",      default: 1,     null: false
    t.string   "uid",          default: "",    null: false
    t.boolean  "current",      default: true,  null: false
    t.boolean  "offset_trade", default: false, null: false
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
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "role_id",          default: 1, null: false
    t.index ["business_id"], name: "index_users_on_business_id", using: :btree
  end

  add_foreign_key "events", "businesses"
  add_foreign_key "events", "users"
  add_foreign_key "permissions", "roles"
  add_foreign_key "portfolios", "businesses"
  add_foreign_key "roles", "businesses"
  add_foreign_key "trades", "portfolios"
  add_foreign_key "trades", "securities"
  add_foreign_key "users", "businesses"
end
