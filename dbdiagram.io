Table users {
  id bigint [pk, increment]
  user_name varchar [not null, note: "名前"]
  provider varchar [not null]
  uid varchar [not null]
  description_read boolean [default: false, not null, note: "アプリ説明読了フラグ"]
  created_at timestamp [not null]
  updated_at timestamp [not null]
  
  indexes {
    (provider, uid) [unique]
  }
  
  Note: 'ユーザー'
}

Table medication_groups {
  id bigint [pk, increment]
  group_name varchar [not null]
  created_at timestamp [not null]
  updated_at timestamp [not null]
  
  Note: '服薬グループ'
}

Table medication_group_users {
  id bigint [pk, increment]
  medication_group_id bigint [not null]
  user_id bigint [not null]
  user_type varchar [not null, note: "ユーザー区分 medication_taker:服薬者 family_watcher:見守り家族"]
  created_at timestamp [not null]
  updated_at timestamp [not null]
  
  Note: '服薬グループユーザー'
}

Table medication_group_invitations {
  id bigint [pk, increment]
  medication_group_id bigint [not null]
  user_id bigint [not null]
  max_uses integer [default: 1, not null, note: "最大使用数"]
  used_count integer [default: 0, not null, note: "使用回数"]
  expires_at timestamp [note: "有効期限"]
  created_at timestamp [not null]
  updated_at timestamp [not null]
  
  Note: '服薬グループ招待'
}

Table medication_schedules {
  id bigint [pk, increment]
  medication_group_id bigint [not null]
  title varchar [not null]
  medication_time time [not null, note: "服薬時刻"]
  reminder_count integer [default: 0]
  reminder_interval integer [note: "リマインド間隔（分）"]
  family_notification_delay integer [note: "家族通知待機時間（分）"]
  created_at timestamp [not null]
  updated_at timestamp [not null]
  
  Note: '服薬スケジュール'
}

Table schedule_drugs {
  id bigint [pk, increment]
  medication_schedule_id bigint [not null]
  drug_name varchar [not null, note: "薬剤名"]
  created_at timestamp [not null]
  updated_at timestamp [not null]
  
  Note: '服薬薬剤'
}

Table medication_managements {
  id bigint [pk, increment]
  medication_schedule_id bigint [not null]
  medication_group_id bigint [not null]
  medication_date date [not null]
  is_taken boolean [default: false, not null, note: "0:未服薬 1:服薬済み"]
  completed_at timestamp [note: "服薬済み時刻"]
  reminder_sent_count integer [default: 0, not null, note: "リマインダー送信回数"]
  original_schedule_title varchar
  created_at timestamp [not null]
  updated_at timestamp [not null]
  
  Note: '服薬管理'
}

Table reward_conditions {
  id bigint [pk, increment]
  medication_group_id bigint [not null]
  reward_name varchar [not null, note: "ご褒美名"]
  condition_type varchar [not null, note: "条件タイプ weekly:1週間 daily_streak:連続日数"]
  target_weekday varchar [note: "曜日 条件タイプが1:1週間の場合に利用する"]
  target_value integer [note: "連続目標値"]
  created_at timestamp [not null]
  updated_at timestamp [not null]
  
  Note: 'ご褒美管理'
}

Table reward_histories {
  id bigint [pk, increment]
  medication_group_id bigint [not null]
  medication_management_id bigint [note: "ご褒美獲得時の最終服薬 次回のカウント開始に利用"]
  reward_name varchar [not null, note: "ご褒美名"]
  reward_date date [not null, note: "ご褒美獲得日"]
  created_at timestamp [not null]
  updated_at timestamp [not null]
  
  Note: 'ご褒美履歴'
}

// Relationships based on Rails models
Ref: medication_groups.id < medication_group_users.medication_group_id
Ref: users.id < medication_group_users.user_id
Ref: medication_groups.id < medication_group_invitations.medication_group_id
Ref: users.id < medication_group_invitations.user_id
Ref: medication_groups.id < medication_schedules.medication_group_id
Ref: medication_schedules.id < schedule_drugs.medication_schedule_id
Ref: medication_schedules.id < medication_managements.medication_schedule_id
Ref: medication_groups.id < medication_managements.medication_group_id
Ref: medication_groups.id < reward_conditions.medication_group_id
Ref: medication_groups.id < reward_histories.medication_group_id
Ref: medication_managements.id - reward_histories.medication_management_id