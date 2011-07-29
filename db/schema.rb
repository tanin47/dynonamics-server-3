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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110729113517) do

  create_table "aesirs", :force => true do |t|
    t.string   "username"
    t.datetime "created_date"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text     "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dyno_histories", :force => true do |t|
    t.integer  "before_number"
    t.integer  "after_number"
    t.datetime "created_time"
    t.integer  "user_id"
    t.decimal  "before_avg_waiting_time",   :precision => 17, :scale => 6, :default => 0.0
    t.decimal  "before_avg_service_time",   :precision => 17, :scale => 6, :default => 0.0
    t.decimal  "before_wanted_time",        :precision => 17, :scale => 6, :default => 0.0
    t.integer  "before_number_of_requests",                                :default => 0
  end

  add_index "dyno_histories", ["created_time", "user_id"], :name => "index_dyno_histories_on_created_time_and_user_id"

  create_table "logs", :force => true do |t|
    t.decimal  "incoming_time",                 :precision => 17, :scale => 6
    t.integer  "user_id"
    t.decimal  "http_x_request_start",          :precision => 17, :scale => 6
    t.decimal  "rails_start",                   :precision => 17, :scale => 6
    t.decimal  "rails_end",                     :precision => 17, :scale => 6
    t.decimal  "http_x_heroku_queue_wait_time", :precision => 17, :scale => 6
    t.integer  "http_x_heroku_dyno_in_use"
    t.integer  "http_x_heroku_queue_depth"
    t.string   "status"
    t.datetime "created_date",                                                 :default => '2011-07-29 11:47:34'
  end

  add_index "logs", ["user_id", "status"], :name => "index_logs_on_user_id_and_status"

  create_table "tuner_logs", :force => true do |t|
    t.text     "data"
    t.text     "error_message"
    t.datetime "created_time"
  end

  create_table "users", :force => true do |t|
    t.string   "dynonamics_key"
    t.string   "username"
    t.string   "api_key"
    t.string   "status"
    t.string   "app_name"
    t.datetime "created_date"
    t.integer  "max_dyno"
    t.decimal  "avg_waiting_time",     :precision => 17, :scale => 6
    t.string   "callback_url"
    t.string   "plan"
    t.string   "heroku_id"
    t.integer  "min_dyno",                                            :default => 1, :null => false
    t.integer  "max_worker",                                          :default => 5, :null => false
    t.integer  "min_worker",                                          :default => 0, :null => false
    t.datetime "last_adjustment_time"
  end

  add_index "users", ["status"], :name => "index_users_on_status"

  create_table "worker_histories", :force => true do |t|
    t.integer  "before_number"
    t.integer  "after_number"
    t.datetime "created_time"
    t.integer  "user_id"
  end

end
