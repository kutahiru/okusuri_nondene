# 通知関連のDB更新サービスクラス
class NotificationDatabaseService
  # 通知スケジュールの取得
  def self.get_notification_data
    sql = <<~SQL
    --対象となるスケジュールを取得
    --1時間前後のスケジュールを取得する
    SELECT
       sch.id AS medication_schedule_id
      ,NULL AS medication_management_id
      ,sch.title AS schedule_title
      ,CURRENT_DATE + sch.medication_time AS medication_date_time
      ,CURRENT_DATE + sch.medication_time + (sch.family_notification_delay * INTERVAL '1 minute') AS family_notification_date_time
      ,u.id AS user_id
      ,u.uid
      ,gu.user_type --0:服薬者 1:見守り家族
    FROM medication_schedules sch
    LEFT JOIN medication_managements ma ON
          sch.id = ma.medication_schedule_id
      AND ma.medication_date = CURRENT_DATE
    INNER JOIN medication_group_users gu ON
      sch.medication_group_id = gu.medication_group_id
    INNER JOIN users u ON
      gu.user_id = u.id
    WHERE ma.id IS NULL --管理テーブルにレコード未作成
      AND CASE
        WHEN CURRENT_TIME >= '23:00:00' --23時を超えている場合は、24時未満のスケジュールのみ取得
    	  THEN  medication_time >= CURRENT_TIME - INTERVAL '1 hour'
    	    AND medication_time < '24:00:00'
        WHEN CURRENT_TIME < '01:00:00' --1時未満の場合は、0時以降のスケジュールのみ取得
    	  THEN  medication_time >= '0:00:00'
    	    AND medication_time < CURRENT_TIME + INTERVAL '1 hour'
        ELSE
    	  medication_time BETWEEN CURRENT_TIME - INTERVAL '1 hour' AND CURRENT_TIME + INTERVAL '1 hour'
        END
    ORDER BY sch.id, u.id
    SQL

    result = ActiveRecord::Base.connection.exec_query(
      sql,
      "notification_data",
    )

    result.map do |row|
      p row
      MedicationScheduleTarget.new(row.to_h)
    end
  end

  # 管理テーブル作成
  def self.insert_medication_management(notification_target)
    medication_management = MedicationManagement.find_or_create_by(
      medication_schedule_id: notification_target.medication_schedule_id,
      medication_date: notification_target.medication_date_time.to_date
      )

    medication_management
  end
end
