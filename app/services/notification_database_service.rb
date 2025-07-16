# 通知関連のDB更新サービスクラス
class NotificationDatabaseService
  # 通知スケジュールの取得
  def self.get_notification_data
    ActiveRecord::Base.transaction do
      # トランザクション内でタイムゾーンを東京時間に設定（ローカルスコープ）
      ActiveRecord::Base.connection.execute("SET LOCAL TIME ZONE 'Asia/Tokyo'")

      sql = <<~SQL
      --対象となるスケジュールを取得
      --1時間後までのスケジュールを取得する
      SELECT
         sch.id AS medication_schedule_id
        ,NULL AS medication_management_id
        ,sch.title AS schedule_title
        ,CASE WHEN CURRENT_TIME > '23:00:00' AND sch.medication_time <= CURRENT_TIME + INTERVAL '1 hour'
          THEN CURRENT_DATE + INTERVAL '1 day' + sch.medication_time
          ELSE CURRENT_DATE + sch.medication_time
         END AS medication_date_time
        ,CASE WHEN CURRENT_TIME > '23:00:00' AND sch.medication_time <= CURRENT_TIME + INTERVAL '1 hour'
           THEN CURRENT_DATE + INTERVAL '1 day' + sch.medication_time + (sch.family_notification_delay * INTERVAL '1 minute')
           ELSE CURRENT_DATE + sch.medication_time + (sch.family_notification_delay * INTERVAL '1 minute')
         END AS family_notification_date_time
        ,u.id AS user_id
        ,u.uid
        ,gu.user_type --medication_taker:服薬者 family_watcher:見守り家族
        ,sch.medication_group_id
        ,g.group_name
      FROM medication_schedules sch
      INNER JOIN medication_groups g ON
        sch.medication_group_id = g.id
      LEFT JOIN medication_managements ma ON
            sch.id = ma.medication_schedule_id
        AND ma.medication_date =
	      CASE
          WHEN CURRENT_TIME > '23:00:00' AND sch.medication_time <= CURRENT_TIME + INTERVAL '1 hour'
          THEN CURRENT_DATE + INTERVAL '1 day'
          ELSE CURRENT_DATE
        END
      INNER JOIN medication_group_users gu ON
        sch.medication_group_id = gu.medication_group_id
      INNER JOIN users u ON
        gu.user_id = u.id
      WHERE ma.id IS NULL --管理テーブルにレコード未作成
        AND
	    (
          -- 現在時刻 + 1時間が23:59:59以下
          (CURRENT_TIME <= '23:00:00'
             AND medication_time BETWEEN CURRENT_TIME AND CURRENT_TIME + INTERVAL '1 hour')
          OR
          -- 現在時刻が23:00:00より後
          (CURRENT_TIME > '23:00:00'
           AND (medication_time >= CURRENT_TIME --現在時刻～23:59:59が取得対象
             OR medication_time <= CURRENT_TIME + INTERVAL '1 hour')) --0:00～現在時刻の1時間後までが取得対象
        )
      ORDER BY sch.id, u.id
      SQL

      result = ActiveRecord::Base.connection.exec_query(
        sql,
        "notification_data",
      )

      result.map do |row|
        MedicationScheduleTarget.new(row.to_h)
      end
    end
  end

  # 管理テーブル作成
  def self.insert_medication_management(notification_target)
    medication_management = MedicationManagement.find_or_create_by(
      medication_schedule_id: notification_target.medication_schedule_id,
      medication_date: notification_target.medication_date_time.to_date
    ) do |management|
      # 作成時のみ設定
      management.original_schedule_title = notification_target.schedule_title
      management.medication_group_id = notification_target.medication_group_id
    end

    medication_management
  end
end
