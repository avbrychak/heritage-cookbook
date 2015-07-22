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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140217101251) do

  create_table "authorships", :force => true do |t|
    t.integer "user_id"
    t.integer "cookbook_id"
    t.integer "role",        :default => 1, :null => false
  end

  add_index "authorships", ["cookbook_id", "user_id"], :name => "authorships_cookbook_id_user_id_index"
  add_index "authorships", ["user_id", "cookbook_id"], :name => "authorships_user_id_cookbook_id_index"

  create_table "book_bindings", :force => true do |t|
    t.string   "name",                :null => false
    t.integer  "max_number_of_pages", :null => false
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "comatose_page_versions", :force => true do |t|
    t.integer  "page_versions"
    t.integer  "comatose_page_id"
    t.integer  "version"
    t.integer  "parent_id"
    t.text     "full_path"
    t.string   "title"
    t.string   "slug"
    t.string   "keywords"
    t.text     "body"
    t.string   "filter_type",      :limit => 25
    t.string   "author"
    t.integer  "position"
    t.datetime "updated_on"
    t.datetime "created_on"
  end

  create_table "comatose_pages", :force => true do |t|
    t.integer  "parent_id"
    t.string   "full_path"
    t.string   "title"
    t.string   "slug"
    t.text     "body"
    t.string   "author"
    t.integer  "position",                  :default => 0
    t.datetime "updated_on"
    t.string   "filter_type", :limit => 25, :default => "Textile"
    t.text     "keywords"
    t.datetime "created_on"
    t.integer  "version"
  end

  add_index "comatose_pages", ["full_path"], :name => "comatose_pages_full_path_index"

  create_table "cookbooks", :force => true do |t|
    t.integer  "intro_type",                          :default => 0,     :null => false
    t.text     "intro_text"
    t.integer  "template_id",                         :default => 0,     :null => false
    t.string   "title",                               :default => "",    :null => false
    t.string   "user_image_file_name",                :default => ""
    t.string   "tag_line_1",                          :default => "",    :null => false
    t.string   "tag_line_2",                          :default => "",    :null => false
    t.string   "tag_line_3",                          :default => "",    :null => false
    t.string   "tag_line_4",                          :default => "",    :null => false
    t.integer  "grayscale",                           :default => 0,     :null => false
    t.string   "user_cover_image_file_name",          :default => ""
    t.string   "user_inner_cover_image_file_name",    :default => ""
    t.boolean  "center_introduction",                 :default => false
    t.integer  "expired",                             :default => 0,     :null => false
    t.string   "intro_image_file_name"
    t.integer  "intro_image_grayscale",               :default => 0,     :null => false
    t.integer  "inner_cover_image_grayscale",         :default => 0,     :null => false
    t.boolean  "show_index",                          :default => false
    t.integer  "user_image_file_size"
    t.string   "user_image_content_type"
    t.integer  "user_cover_image_file_size"
    t.string   "user_cover_image_content_type"
    t.integer  "user_inner_cover_image_file_size"
    t.string   "user_inner_cover_image_content_type"
    t.integer  "intro_image_file_size"
    t.string   "intro_image_content_type"
    t.boolean  "is_locked_for_printing",              :default => false
    t.datetime "updated_on"
    t.text     "notes"
    t.integer  "book_binding_id",                     :default => 1
    t.integer  "intro_image_dpi"
    t.integer  "user_image_dpi"
    t.integer  "user_cover_image_dpi"
    t.integer  "user_inner_cover_image_dpi"
    t.integer  "intro_image_width"
    t.integer  "user_image_width"
    t.integer  "user_cover_image_width"
    t.integer  "user_inner_cover_image_width"
    t.integer  "intro_image_height"
    t.integer  "user_image_height"
    t.integer  "user_cover_image_height"
    t.integer  "user_inner_cover_image_height"
  end

  add_index "cookbooks", ["book_binding_id"], :name => "index_cookbooks_on_book_binding_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "extra_pages", :force => true do |t|
    t.integer  "section_id",                        :default => 0,     :null => false
    t.integer  "user_id",                           :default => 0,     :null => false
    t.string   "name",               :limit => 100, :default => "",    :null => false
    t.string   "photo_file_name",                   :default => ""
    t.integer  "grayscale",                         :default => 0,     :null => false
    t.text     "text",                                                 :null => false
    t.float    "pages",                             :default => 0.0,   :null => false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.boolean  "index_as_recipe",                   :default => false
    t.integer  "photo_file_size"
    t.string   "photo_content_type"
    t.integer  "photo_width"
    t.integer  "photo_height"
    t.integer  "photo_dpi"
  end

  add_index "extra_pages", ["section_id"], :name => "extra_pages_section_id_index"
  add_index "extra_pages", ["user_id"], :name => "extra_pages_user_id_index"

  create_table "gift_cards", :force => true do |t|
    t.integer  "plan_id"
    t.integer  "user_id"
    t.string   "bill_name",        :default => "",    :null => false
    t.string   "bill_address",     :default => "",    :null => false
    t.string   "bill_city",        :default => "",    :null => false
    t.string   "bill_postal_code", :default => "",    :null => false
    t.string   "bill_state",       :default => "",    :null => false
    t.string   "bill_country",     :default => "",    :null => false
    t.string   "bill_phone",       :default => "",    :null => false
    t.string   "bill_email",       :default => "",    :null => false
    t.string   "message",          :default => "",    :null => false
    t.boolean  "is_paid",          :default => false, :null => false
    t.string   "transaction_data", :default => "",    :null => false
    t.datetime "created_on"
    t.datetime "redeemed_on"
    t.datetime "give_on"
    t.datetime "notified_on"
  end

  add_index "gift_cards", ["give_on"], :name => "gift_cards_give_on_index"
  add_index "gift_cards", ["plan_id"], :name => "gift_cards_plan_id_index"

  create_table "lib_images", :force => true do |t|
    t.string  "lib_image_file_name"
    t.integer "lib_image_file_size"
    t.string  "lib_image_content_type"
  end

  create_table "membership_changes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.integer  "number_of_books"
    t.date     "expiry_date"
    t.text     "transaction_data"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "express_token"
    t.string   "express_payer_id"
  end

  create_table "orders", :force => true do |t|
    t.integer  "cookbook_id",                        :default => 0,  :null => false
    t.integer  "number_of_books",                    :default => 0,  :null => false
    t.string   "bill_first_name",     :limit => 50,  :default => "", :null => false
    t.string   "bill_last_name",      :limit => 50,  :default => "", :null => false
    t.string   "bill_address",        :limit => 50,  :default => "", :null => false
    t.string   "bill_address2",                      :default => "", :null => false
    t.string   "bill_city",                          :default => "", :null => false
    t.string   "bill_zip",            :limit => 10,  :default => "", :null => false
    t.string   "bill_country",        :limit => 50,  :default => "", :null => false
    t.string   "bill_state",          :limit => 100, :default => "", :null => false
    t.string   "bill_phone",          :limit => 15,  :default => "", :null => false
    t.string   "bill_email",          :limit => 100, :default => "", :null => false
    t.string   "ship_first_name",     :limit => 50,  :default => "", :null => false
    t.string   "ship_last_name",      :limit => 50,  :default => "", :null => false
    t.string   "ship_address",        :limit => 50,  :default => "", :null => false
    t.string   "ship_address2",                      :default => "", :null => false
    t.string   "ship_city",                          :default => "", :null => false
    t.string   "ship_zip",            :limit => 10,  :default => "", :null => false
    t.string   "ship_country",        :limit => 50,  :default => "", :null => false
    t.string   "ship_state",          :limit => 100, :default => "", :null => false
    t.string   "ship_phone",          :limit => 15,  :default => "", :null => false
    t.string   "ship_email",          :limit => 100, :default => "", :null => false
    t.datetime "paid_on"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.text     "transaction_data"
    t.datetime "generated_at"
    t.string   "filename"
    t.text     "notes"
    t.integer  "order_color_pages"
    t.integer  "order_bw_pages"
    t.float    "order_printing_cost"
    t.float    "order_shipping_cost"
    t.string   "delivery_time"
    t.integer  "reorder_id"
    t.integer  "version",                            :default => 1,  :null => false
    t.string   "old_ship_phone",                     :default => "", :null => false
    t.string   "old_bill_phone",                     :default => "", :null => false
    t.integer  "user_id"
    t.string   "book_binding"
    t.string   "cookbook_title"
  end

  add_index "orders", ["cookbook_id", "paid_on"], :name => "orders_cookbook_id_index"

  create_table "plans", :force => true do |t|
    t.string  "title",           :default => "",  :null => false
    t.integer "duration",        :default => 0,   :null => false
    t.float   "price",           :default => 0.0, :null => false
    t.integer "number_of_books", :default => 0,   :null => false
    t.integer "purchaseable",    :default => 1
    t.integer "upgradeable",     :default => 0
  end

  create_table "recipes", :force => true do |t|
    t.integer  "section_id",                                  :default => 0,               :null => false
    t.string   "name",                         :limit => 100, :default => "",              :null => false
    t.string   "servings",                     :limit => 40,  :default => "1 Person",      :null => false
    t.text     "ingredient_list",                                                          :null => false
    t.text     "instructions",                                                             :null => false
    t.text     "story",                                                                    :null => false
    t.string   "photo_file_name",                             :default => ""
    t.string   "submitted_by",                 :limit => 50,  :default => "",              :null => false
    t.integer  "grayscale",                                   :default => 0,               :null => false
    t.float    "pages",                                       :default => 0.0,             :null => false
    t.integer  "shared",                                      :default => 0,               :null => false
    t.integer  "position",                                    :default => 1,               :null => false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.integer  "user_id",                                     :default => 0,               :null => false
    t.string   "photo_archive",                :limit => 100, :default => "",              :null => false
    t.integer  "force_own_page"
    t.string   "submitted_by_title",                          :default => "Submitted by:", :null => false
    t.boolean  "ingredients_uses_two_columns",                :default => false,           :null => false
    t.text     "ingredient_list_2"
    t.integer  "photo_file_size"
    t.string   "photo_content_type"
    t.integer  "photo_width"
    t.integer  "photo_height"
    t.boolean  "single_page"
    t.integer  "photo_dpi"
  end

  add_index "recipes", ["section_id", "user_id"], :name => "recipes_section_id_user_id_index"
  add_index "recipes", ["user_id", "section_id"], :name => "recipes_user_id_section_id_index"

  create_table "sections", :force => true do |t|
    t.integer "cookbook_id",                      :default => 0,  :null => false
    t.string  "name",               :limit => 25, :default => "", :null => false
    t.integer "position",                         :default => 0,  :null => false
    t.integer "section_image_id"
    t.string  "photo_file_name"
    t.integer "photo_file_size"
    t.string  "photo_content_type"
    t.integer "photo_dpi"
    t.integer "photo_width"
    t.integer "photo_height"
  end

  add_index "sections", ["cookbook_id", "section_image_id"], :name => "sections_cookbook_id_section_image_id_index"
  add_index "sections", ["section_image_id", "cookbook_id"], :name => "sections_section_image_id_cookbook_id_index"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
  end

  add_index "taggings", ["tag_id", "taggable_id"], :name => "taggings_tag_id_taggable_id_index"
  add_index "taggings", ["taggable_id", "tag_id"], :name => "taggings_taggable_id_tag_id_index"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "templates", :force => true do |t|
    t.string  "name",          :limit => 50, :default => "", :null => false
    t.integer "template_type",               :default => 1,  :null => false
    t.text    "description"
    t.integer "position"
  end

  create_table "textblocks", :force => true do |t|
    t.string "name"
    t.string "description"
    t.text   "text"
    t.text   "text_html"
  end

  add_index "textblocks", ["name"], :name => "textblocks_name_index"

  create_table "users", :force => true do |t|
    t.string   "first_name",         :limit => 50,  :default => "",    :null => false
    t.string   "last_name",          :limit => 50,  :default => "",    :null => false
    t.string   "address",            :limit => 50,  :default => "",    :null => false
    t.string   "zip",                :limit => 10,  :default => "",    :null => false
    t.string   "state",              :limit => 100, :default => "",    :null => false
    t.string   "phone",              :limit => 15,  :default => "",    :null => false
    t.string   "email",              :limit => 100, :default => "",    :null => false
    t.string   "hashed_password",    :limit => 40,  :default => "",    :null => false
    t.string   "country",            :limit => 50,  :default => "",    :null => false
    t.string   "address2",                          :default => "",    :null => false
    t.string   "city",                              :default => "",    :null => false
    t.string   "how_heard",                         :default => "",    :null => false
    t.string   "newsletter",                        :default => "",    :null => false
    t.string   "cookbook_type",                     :default => "",    :null => false
    t.integer  "plan_id"
    t.date     "expiry_date"
    t.string   "confirm_key",        :limit => 40
    t.datetime "created_on"
    t.datetime "last_login_on"
    t.integer  "login_count",                       :default => 0,     :null => false
    t.text     "transaction_data"
    t.integer  "number_of_books",                   :default => 0,     :null => false
    t.string   "old_phone",                         :default => "",    :null => false
    t.integer  "recipes_count",                     :default => 0
    t.boolean  "is_old_user",                       :default => true
    t.boolean  "has_been_contacted",                :default => false
    t.text     "notes"
    t.integer  "paid_orders_count",                 :default => 0
    t.string   "express_token"
    t.string   "express_payer_id"
  end

  add_index "users", ["created_on", "plan_id"], :name => "users_created_on_plan_id_index"
  add_index "users", ["email", "hashed_password"], :name => "users_email_index"
  add_index "users", ["plan_id", "created_on"], :name => "users_plan_id_created_on_index"

end
