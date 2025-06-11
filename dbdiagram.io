Table users {
  id int [pk]
  user_name varchar [note: "名前"]
  provider varchar
  uid  varchar 
  description_read bool [note: "アプリ説明読了フラグ"]
  Note: 'ユーザー'
}

Table medication_groups {
  id int [pk]
  group_name varchar
  Note: '服薬グループ'
}

Table medication_group_users {
  id int [pk]
  medication_group_id int
  user_id int
  user_type varchar [note: "ユーザー区分 0:服薬者 1:見守り家族"]
  Note: '服薬グループユーザー'
}

Table medication_schedules {
  id int [pk]
  medication_group_id int
  medication_time time [note: "服薬時刻"]
  reminder_count int
  reminder_interval int [note: "リマインド間隔（分）"]
  family_notification_delay int [note: "家族通知待機時間（分）"]
  Note: '服薬スケジュール'
}

Table schedule_drugs {
  id int [pk]
  medication_schedules_id int
  drug_name varchar [note: "薬剤名"]
  Note: '服薬薬剤'
}

Table medication_managements {
  id int [pk]
  medication_schedules_id int
  medication_date date
  is_taken bool [note: "0:未服薬 1:服薬済み"]
  completed_at datetime [note: "服薬済み時刻"]
  reminder_sent_count int [note: "リマインダー送信回数"]
  Note: '服薬管理'
}

Table medication_histories {
  id int [pk]
  user_id int
  medication_date date
  drug_name varchar [note: "薬剤名"]
  completed_at datetime [note: "服薬済み時刻"]
  Note: '服薬履歴 薬剤名ありの履歴確認時に使用'
}

Table reward_conditions {
  id int [pk]
  medication_group_id int
  reward_name varchar [note: "ご褒美名"]
  condition_type varchar [note: "条件タイプ 0:ご褒美なし 1:1週間 2:連続日数"]
  target_weekday varchar [note: "曜日 条件タイプが1:1週間の場合に利用する"]
  target_value int [note: "連続目標値"]
  Note: 'ご褒美'
}

Table reward_histories {
  id int [pk]
  medication_group_id int
  reward_name varchar [note: "ご褒美名"]
  reward_date date [note: "ご褒美獲得日"]
  medication_managements_id id [note: "ご褒美獲得時の最終服薬 次回のカウント開始に利用"]
  Note: 'ご褒美'
}

Table active_storage_blobs {
  dummy string
}

Table active_storage_attachments {
  dummy string
}

Table active_storage_variant_records {
  dummy string
}

Ref: "medication_groups"."id" < "medication_group_users"."medication_group_id"
Ref: "users"."id" <> "medication_group_users"."user_id"
Ref: "medication_groups"."id" < "medication_schedules"."medication_group_id"
Ref: "medication_schedules"."id" < "medication_managements"."medication_schedules_id"
Ref: "medication_schedules"."id" < "schedule_drugs"."medication_schedules_id"
Ref: "users"."id" < "medication_histories"."user_id"  
Ref: "medication_groups"."id" - "reward_conditions"."medication_group_id"
Ref: "medication_groups"."id" < "reward_histories"."medication_group_id"
Ref: "medication_managements"."id" - "reward_histories"."medication_managements_id"