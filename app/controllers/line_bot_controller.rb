class LineBotController < ApplicationController
  def callback
    body = request.body.read # LINEから送られたJSONデータ
    signature = request.env["HTTP_X_LINE_SIGNATURE"] # LINEが送ってきた署名

    begin
      # LINEからの生データを検証してオブジェクトに変更
      events = webhook_parser.parse(body: body, signature: signature)

      events.each do |event|
        handle_event(event)
      end

      head :ok # 待機しているLINE側に成功を通知
    rescue Line::Bot::V2::WebhookParser::InvalidSignatureError
      logger.error "Invalid signature from LINE"
      head :bad_request
    end
  end

  private

  def webhook_parser
    @webhook_parser ||= Line::Bot::V2::WebhookParser.new(
      channel_secret: Rails.application.credentials.dig(:line_message, :channel_secret)
    )
  end

  def handle_event(event)
    case event
    when Line::Bot::V2::Webhook::PostbackEvent
      handle_post_back_event(event)
    when Line::Bot::V2::Webhook::MessageEvent
      handle_message_event(event)           # メッセージが来た時
    when Line::Bot::V2::Webhook::FollowEvent
      handle_follow_event(event)            # フォローされた時
    when Line::Bot::V2::Webhook::UnfollowEvent
      handle_unfollow_event(event)          # フォローを外された時
    end
  end
end
