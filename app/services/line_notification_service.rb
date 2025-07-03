class LineNotificationService
  def self.send_line_message_with_button(medication_management_id, uid, group_name, message_text)
    # ボタンにIDを埋め込む
    taken_data = "medication_taken_#{medication_management_id}"

    lines = [
      group_name,
      message_text,
      "おくすり飲んでね",
      ENV["APP_BASE_URL"]
    ]

    button_message_text = lines.join("\n")

    buttons_template = Line::Bot::V2::MessagingApi::ButtonsTemplate.new(
      text: button_message_text,
      actions: [
        Line::Bot::V2::MessagingApi::PostbackAction.new(
          label: "おくすり飲んだよ",
          data: taken_data,
          display_text: "おくすり飲んだよ"
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

  # 見守り家族に服薬済を通知
  def self.family_watcher_send_line_message(medication_management)
    family_watchers = find_family_watchers(medication_management.medication_group_id)

    lines = [
      medication_management.original_schedule_title,
      "おくすり飲んだよ",
      ENV["APP_BASE_URL"]
    ]

    message_text = lines.join("\n")

    family_watchers.each do |family_watcher|
       send_line_message(family_watcher.user.uid, message_text)
    end
  end

  def self.find_family_watchers(medication_group_id)
    MedicationGroupUser
      .includes(:user)
      .where(medication_group_id: medication_group_id)
      .family_watcher
  end

  # シンプルなメッセージの送信
  def self.send_line_message(uid, group_name, message_text)
    lines = [
      group_name,
      message_text,
      ENV["APP_BASE_URL"]
    ]

    push_message_text = lines.join("\n")

    # メッセージリクエストを作成
    push_request = Line::Bot::V2::MessagingApi::PushMessageRequest.new(
      to: uid,
      messages: [
        Line::Bot::V2::MessagingApi::TextMessage.new(text: push_message_text)
      ]
    )

    # メッセージ送信
    response, status_code, headers = client.push_message_with_http_info(
      push_message_request: push_request
    )

    status_code == 200
  end

  private

  def self.client
    @client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: Rails.application.credentials.dig(:line_message, :channel_access_token)
    )
  end
end
