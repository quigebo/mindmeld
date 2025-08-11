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

ActiveRecord::Schema[8.0].define(version: 2025_08_11_150600) do
  create_table "comments", force: :cascade do |t|
    t.integer "commentable_id"
    t.string "commentable_type"
    t.string "title"
    t.text "body"
    t.string "subject"
    t.integer "user_id", null: false
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_memory_worthy", default: false
    t.json "llm_analysis"
    t.string "location"
    t.datetime "occurred_at"
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
    t.index ["is_memory_worthy"], name: "index_comments_on_is_memory_worthy"
    t.index ["lft", "rgt"], name: "index_comments_on_lft_and_rgt"
    t.index ["occurred_at"], name: "index_comments_on_occurred_at"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "participants", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "story_id", null: false
    t.string "status"
    t.datetime "invited_at"
    t.datetime "joined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_participants_on_status"
    t.index ["story_id"], name: "index_participants_on_story_id"
    t.index ["user_id", "story_id"], name: "index_participants_on_user_id_and_story_id", unique: true
    t.index ["user_id"], name: "index_participants_on_user_id"
  end

  create_table "stories", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "creator_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_stories_on_creator_id"
  end

  create_table "synthesized_memories", force: :cascade do |t|
    t.integer "story_id", null: false
    t.text "content"
    t.json "metadata"
    t.datetime "generated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id"], name: "index_synthesized_memories_on_story_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object", limit: 1073741823
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "participants", "stories"
  add_foreign_key "participants", "users"
  add_foreign_key "stories", "users", column: "creator_id"
  add_foreign_key "synthesized_memories", "stories"
end
