class LineNotificationJob < ApplicationJob
  queue_as :notifications
  sidekiq_options retry: false

  def perform
    user = User.find(1)
    line_notification_service = LineNotificationService.new
    line_notification_service.send_line_message(user.uid, "テストメッセージ")
  end
end
