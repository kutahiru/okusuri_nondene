class LineNotificationService
  # ボタン付きの服薬通知
  def self.send_line_message_with_button(medication_management_id, uid, group_name, message_text)
    # ボタンにIDを埋め込む
    taken_data = "medication_taken_#{medication_management_id}"

    lines = [
      group_name,
      message_text,
      "⏰おくすり飲んでね"
    ]

    button_message_text = lines.join("\n")

    buttons_template = Line::Bot::V2::MessagingApi::ButtonsTemplate.new(
      text: button_message_text,
      actions: [
        Line::Bot::V2::MessagingApi::URIAction.new(
          label: "アプリにアクセス",
          uri: ENV["APP_BASE_URL"]
        ),
        Line::Bot::V2::MessagingApi::PostbackAction.new(
          label: "✅おくすり飲んだよ",
          data: taken_data,
          display_text: "✅おくすり飲んだよ"
        )
      ]
    )

    template_message = Line::Bot::V2::MessagingApi::TemplateMessage.new(
      alt_text: message_text,
      template: buttons_template
    )

    push_request = Line::Bot::V2::MessagingApi::PushMessageRequest.new(
        to: uid,
        messages: [ template_message ]
      )

    # メッセージ送信
    response, status_code, headers = client.push_message_with_http_info(
      push_message_request: push_request
    )

    status_code == 200
  end

  # 見守り家族に未服薬を通知
  def self.family_watcher_notification_delay_send_line_message(uid, group_name, schedule_title)
    lines = [
      group_name,
      schedule_title,
      "⏰まだおくすり飲めてないよ",
      "", # 空行
      "", # 空行
      ENV["APP_BASE_URL"]
    ]

    message_text = lines.join("\n")

    send_line_message(uid, message_text)
  end

  # 見守り家族に服薬済を通知
  def self.family_watcher_medication_taken_send_line_message(medication_management, group_name)
    family_watchers = MedicationGroupUser.find_family_watchers(medication_management.medication_group_id)

    lines = [
      group_name,
      medication_management.original_schedule_title,
      "✅おくすり飲んだよ",
      "", # 空行
      "", # 空行
      ENV["APP_BASE_URL"]
    ]

    message_text = lines.join("\n")

    family_watchers.each do |family_watcher|
       send_line_message(family_watcher.user.uid, message_text)
    end
  end

  # シンプルなメッセージの送信
  def self.send_line_message(uid, message_text)
    # メッセージリクエストを作成
    push_request = Line::Bot::V2::MessagingApi::PushMessageRequest.new(
      to: uid,
      messages: [
        Line::Bot::V2::MessagingApi::TextMessage.new(text: message_text)
      ]
    )

    # メッセージ送信
    response, status_code, headers = client.push_message_with_http_info(
      push_message_request: push_request
    )

    status_code == 200
  end

  # 服薬者にご褒美を通知
  def self.medication_taker_reward_send_line_message(uid, group_name, reward_name)
    lines = [
      group_name,
      reward_name,
      "🎉ご褒美達成🎉",
      "", # 空行
      "", # 空行
      ENV["APP_BASE_URL"]
    ]

    message_text = lines.join("\n")

    send_line_message(uid, message_text)
  end

  # 見守り家族にご褒美を通知
  def self.family_watcher_reward_send_line_message(uid, group_name, reward_name)
    lines = [
      group_name,
      reward_name,
      "🎉ご褒美達成🎉",
      "ご褒美あげてね",
      "", # 空行
      "", # 空行
      ENV["APP_BASE_URL"]
    ]

    message_text = lines.join("\n")

    send_line_message(uid, message_text)
  end

  private

  def self.client
    @client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: Rails.application.credentials.dig(:line_message, :channel_access_token)
    )
  end
end
