class LineNotificationJob < ApplicationJob
  sidekiq_options retry: false

  def perform(target_attributes)
    # ハッシュからオブジェクトを再構築
    notification_target = MedicationScheduleTarget.new(target_attributes)

    medication_management = MedicationManagement.includes(:medication_schedule).find(notification_target.medication_management_id)

    # 服薬済なら通知不要
    return if medication_management.medication_taken?

    if notification_target.medication_taker?
      # 服薬者の場合
      # リマインダー送信回数を加算する(異常時に何度もLINE通知送信を避けるため、送信回数加算が先)
      medication_management.increment!(:reminder_sent_count)
      LineNotificationService.send_line_message_with_button(medication_management.id, notification_target.uid, notification_target.group_name, notification_target.schedule_title)
    else
      # 見守り家族の場合
      # LINE通知送信
      LineNotificationService.send_line_message(notification_target.uid, notification_target.group_name, notification_target.schedule_title)
    end

    # 見守り家族なら終了
    return if notification_target.family_watcher?

    # リマインド回数分通知済みなら通知不要
    return if medication_management.reminder_sent_count > medication_management.medication_schedule.reminder_count

    medication_schedule = medication_management.medication_schedule
    # リマインダー通知間隔を加算
    notification_target.medication_date_time = notification_target.medication_date_time + medication_schedule.reminder_interval.minutes

    # 服薬者のリマインダー通知をJOBキューに登録
    target_hash = notification_target.attributes
    LineNotificationJob.set(wait_until: notification_target.medication_date_time).perform_later(target_hash)
  end
end
