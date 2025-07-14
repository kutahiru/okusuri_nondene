# ご褒美通知関連のDB更新サービスクラス
class RewardDatabaseService
  # ご褒美通知対象を取得
  # 次の時刻の00分00秒を通知時間に設定している。
  # 11:00にJOBを動かして、12:00のキューに入る想定
  def self.get_reward_data
    ActiveRecord::Base.transaction do
      # トランザクション内でタイムゾーンを東京時間に設定（ローカルスコープ）
      ActiveRecord::Base.connection.execute("SET LOCAL TIME ZONE 'Asia/Tokyo'")

      # グループごとに最新のご褒美履歴を取得
      ActiveRecord::Base.connection.execute(<<~SQL)
        SELECT
           rh.medication_group_id
          ,MAX(rh.reward_date) AS max_reward_date
        INTO TEMP max_reward_histories
        FROM reward_histories rh
        GROUP BY rh.medication_group_id
      SQL

      # 曜日条件と連続日数条件を必要な条件を取得
      ActiveRecord::Base.connection.execute(<<~SQL)
        SELECT
           rc.medication_group_id
          ,CASE
            WHEN rc.condition_type = 'weekly' THEN 7
            WHEN rc.condition_type = 'daily_streak' THEN rc.target_value
           END AS target_value --必要な連続日数
        INTO TEMP target_medication_groups
        FROM reward_conditions rc
        LEFT JOIN max_reward_histories rh ON
          rc.medication_group_id = rh.medication_group_id
        WHERE
          (
            -- 曜日条件
            rc.condition_type = 'weekly'
            AND rc.target_weekday = TRIM(TO_CHAR(CURRENT_DATE, 'day'))
            AND (rh.max_reward_date IS NULL OR rh.max_reward_date <= CURRENT_DATE - 7)
          )
          OR
          (
            -- 連続日数条件
            rc.condition_type = 'daily_streak'
            AND (rh.max_reward_date IS NULL OR rh.max_reward_date <= CURRENT_DATE - rc.target_value)
          )
      SQL

      # 「現在日 - t.target_valueの日付」から「昨日」までの間で、全て服薬している日付を取得
      ActiveRecord::Base.connection.execute(<<~SQL)
        SELECT
           mm.medication_group_id
          ,mm.medication_date
          ,bool_and(mm.is_taken) AS is_taken
          ,MAX(t.target_value) AS target_value
        INTO TEMP target_medication_dates
        FROM medication_managements mm
        INNER JOIN target_medication_groups t ON
          mm.medication_group_id = t.medication_group_id
        WHERE mm.medication_date BETWEEN CURRENT_DATE - t.target_value AND CURRENT_DATE - 1 --連続日数～昨日までが集計対象
        GROUP BY mm.medication_group_id, mm.medication_date
        HAVING bool_and(mm.is_taken)
      SQL

      # 最終的な結果を取得
      sql = <<~SQL
        SELECT
           gu.medication_group_id
          ,g.group_name
          ,rc.reward_name
          ,u.id AS user_id
          ,u.uid
          ,gu.user_type
          ,DATE_TRUNC('hour', CURRENT_TIMESTAMP + INTERVAL '1 hour') AS reward_date_time
        FROM medication_group_users gu
        INNER JOIN medication_groups g ON
          gu.medication_group_id = g.id
        INNER JOIN users u ON
          gu.user_id = u.id
        INNER JOIN reward_conditions rc ON
          gu.medication_group_id = rc.medication_group_id
        WHERE gu.medication_group_id IN
          (
          SELECT
             t.medication_group_id
          FROM target_medication_dates t
          GROUP BY t.medication_group_id
          HAVING COUNT(t.*) >= MAX(t.target_value)
          )
        ORDER BY gu.medication_group_id, gu.user_type DESC
      SQL

      result = ActiveRecord::Base.connection.exec_query(
        sql,
        "reward_data"
      )

      result.map do |row|
        RewardTarget.new(row.to_h)
      end
    end
  end

  # ご褒美履歴を作成
  def self.insert_reward_history(reward_target)
    RewardHistory.find_or_create_by(
      medication_group_id: reward_target.medication_group_id,
      reward_name: reward_target.reward_name,
      reward_date: reward_target.reward_date_time.to_date,
    )
  end
end
