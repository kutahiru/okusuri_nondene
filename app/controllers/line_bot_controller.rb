class LineBotController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  # 服薬済通知を受信する
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
    end
  end

  # 服薬済に変更する
  def handle_post_back_event(event)
    if event.postback && (match_data = event.postback.data.match(/^medication_taken_(\d+)$/))
      medication_management_id = match_data[1].to_i
      MedicationManagement.update_is_taken!(medication_management_id)
    end
  end
end
