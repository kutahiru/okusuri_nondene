class LineNotificationService
  def self.send_line_message(medication_management_id, uid, message_text)
    # ボタンにIDを埋め込む
    taken_data = "medication_taken_#{medication_management_id}"

    buttons_template = Line::Bot::V2::MessagingApi::ButtonsTemplate.new(
      text: message_text,
      actions: [
        Line::Bot::V2::MessagingApi::PostbackAction.new(
          label: "服薬しました",
          data: taken_data,
          display_text: "服薬しました"
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

  private

  def self.client
    @client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: Rails.application.credentials.dig(:line_message, :channel_access_token)
    )
  end
end
