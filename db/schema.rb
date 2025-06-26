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

ActiveRecord::Schema[7.2].define(version: 2025_06_22_203858) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "medication_group_invitations", comment: "服薬グループ招待", force: :cascade do |t|
    t.bigint "medication_group_id", null: false
    t.bigint "user_id", null: false
    t.integer "max_uses", default: 1, null: false, comment: "最大使用数"
    t.integer "used_count", default: 0, null: false, comment: "使用回数"
    t.datetime "expires_at", comment: "有効期限"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medication_group_id"], name: "index_medication_group_invitations_on_medication_group_id"
    t.index ["user_id"], name: "index_medication_group_invitations_on_user_id"
  end

  create_table "medication_group_users", comment: "服薬グループユーザー", force: :cascade do |t|
    t.bigint "medication_group_id", null: false
    t.bigint "user_id", null: false
    t.string "user_type", null: false, comment: "ユーザー区分 medication_taker:服薬者 family_watcher:見守り家族"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medication_group_id"], name: "index_medication_group_users_on_medication_group_id"
    t.index ["user_id"], name: "index_medication_group_users_on_user_id"
  end

  create_table "medication_groups", comment: "服薬グループ", force: :cascade do |t|
    t.string "group_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "medication_managements", comment: "服薬管理", force: :cascade do |t|
    t.bigint "medication_schedule_id", null: false
    t.date "medication_date", null: false
    t.boolean "is_taken", default: false, null: false, comment: "0:未服薬 1:服薬済み"
    t.datetime "completed_at", comment: "服薬済み時刻"
    t.integer "reminder_sent_count", default: 0, null: false, comment: "リマインダー送信回数"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "original_schedule_title"
    t.bigint "medication_group_id", null: false
    t.index ["medication_group_id"], name: "index_medication_managements_on_medication_group_id"
    t.index ["medication_schedule_id"], name: "index_medication_managements_on_medication_schedule_id"
  end

  create_table "medication_schedules", comment: "服薬スケジュール", force: :cascade do |t|
    t.bigint "medication_group_id", null: false
    t.string "title", null: false
    t.time "medication_time", null: false, comment: "服薬時刻"
    t.integer "reminder_count", default: 0
    t.integer "reminder_interval", comment: "リマインド間隔（分）"
    t.integer "family_notification_delay", comment: "家族通知待機時間（分）"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medication_group_id"], name: "index_medication_schedules_on_medication_group_id"
  end

  create_table "reward_conditions", comment: "ご褒美管理", force: :cascade do |t|
    t.bigint "medication_group_id", null: false
    t.string "reward_name", null: false, comment: "ご褒美名"
    t.string "condition_type", null: false, comment: "条件タイプ weekly:1週間 daily_streak:連続日数"
    t.string "target_weekday", comment: "曜日 条件タイプが1:1週間の場合に利用する"
    t.integer "target_value", comment: "連続目標値"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medication_group_id"], name: "index_reward_conditions_on_medication_group_id"
  end

  create_table "reward_histories", comment: "ご褒美履歴", force: :cascade do |t|
    t.bigint "medication_group_id", null: false
    t.string "reward_name", null: false, comment: "ご褒美名"
    t.date "reward_date", null: false, comment: "ご褒美獲得日"
    t.bigint "medication_managements_id", comment: "ご褒美獲得時の最終服薬 次回のカウント開始に利用"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medication_group_id"], name: "index_reward_histories_on_medication_group_id"
    t.index ["medication_managements_id"], name: "index_reward_histories_on_medication_managements_id"
  end

  create_table "schedule_drugs", comment: "服薬薬剤", force: :cascade do |t|
    t.bigint "medication_schedule_id", null: false
    t.string "drug_name", null: false, comment: "薬剤名"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medication_schedule_id"], name: "index_schedule_drugs_on_medication_schedule_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "user_name", null: false, comment: "名前"
    t.string "provider", null: false
    t.string "uid", null: false
    t.boolean "description_read", default: false, null: false, comment: "アプリ説明読了フラグ"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "medication_group_invitations", "medication_groups"
  add_foreign_key "medication_group_invitations", "users"
  add_foreign_key "medication_group_users", "medication_groups"
  add_foreign_key "medication_group_users", "users"
  add_foreign_key "medication_managements", "medication_groups"
  add_foreign_key "medication_managements", "medication_schedules"
  add_foreign_key "medication_schedules", "medication_groups"
  add_foreign_key "reward_conditions", "medication_groups"
  add_foreign_key "reward_histories", "medication_groups"
  add_foreign_key "reward_histories", "medication_managements", column: "medication_managements_id"
  add_foreign_key "schedule_drugs", "medication_schedules"
end
