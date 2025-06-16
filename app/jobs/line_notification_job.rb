class LineNotificationJob < ApplicationJob
  queue_as :notifications
  sidekiq_options retry: false

  def perform(notification_target)
    medication_management = MedicationManagement.includes(:medication_schedule).find(notification_target.medication_management_id)

    # 服薬済なら通知不要
    return if medication_management.taken?

    # LINE通知送信
    LineNotificationService.send_line_message(notification_target.uid, notification_target.schedule_title)

    # 見守り家族なら終了
    return if notification_target.family_watcher?

    # リマインダー送信回数を加算する
    medication_management.increment!(:reminder_sent_count)

    # リマインド回数分通知済みなら通知不要
    return if medication_management.reminder_sent_count >= medication_management.medication_schedule.reminder_count

    # リマインダー通知間隔を加算
    notification_target.medication_date_time = notification_target.medication_date_time + notification_target.medication_schedule.reminder_interval.minutes

    LineNotificationJob.perform_at(notification_target.medication_date_time, notification_target)
  end
end
