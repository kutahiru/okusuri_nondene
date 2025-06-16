# 定期実行でmedication_schedulesテーブルからデータを取得し、以下の処理を実施する。
# ・1回目のジョブキューを作成する
# ・管理テーブルを作成する
# 2回目以降のリマインド実行は別処理でキューを作成
class GetNotificationTargetsJob < ApplicationJob
  sidekiq_options retry: false

  def perform
    # 通知対象を取得
    notification_targets = NotificationDatabaseService.get_notification_data
    notification_targets.each do |target|
      # 管理テーブルを作成
      medication_management = NotificationDatabaseService.insert_medication_management(target)
      target.medication_management_id = medication_management.id

      if target.medication_taker?
        # 服薬者の通知をJOBキューに登録
        LineNotificationJob.perform_at(target.medication_date_time, target)
      else
        # 見守り家族の通知をJOBキューに登録
        LineNotificationJob.perform_at(target.family_notification_date_time, target)
      end
    end
  end
end
