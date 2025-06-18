class LineNotificationService
  def self.send_line_message(user_id, message_text)
    # メッセージリクエストを作成
    push_request = Line::Bot::V2::MessagingApi::PushMessageRequest.new(
      to: user_id,
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

  private

  def self.client
    @client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: Rails.application.credentials.dig(:line_message, :channel_access_token)
    )
  end
end
