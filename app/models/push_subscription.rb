class PushSubscription < ApplicationRecord
  belongs_to :user

  validates :endpoint, presence: true
  validates :p256dh, presence: true
  validates :auth, presence: true

  scope :active, -> { where(active: true) }

  def subscription_data
    {
      "endpoint" => endpoint,
      "keys" => {
        "p256dh" => p256dh,
        "auth" => auth
      }
    }
  end

  def send_notification(message)
    WebPush.payload_send(
      message: message.to_json,
      endpoint: endpoint,
      p256dh: p256dh,
      auth: auth,
      vapid: {
        subject: "mailto:noreply@okusuri-nondene.com",
        public_key: Rails.application.credentials.vapid.public_key,
        private_key: Rails.application.credentials.vapid.private_key
      },
      ssl_timeout: 5,
      open_timeout: 5,
      read_timeout: 5
    )
  rescue WebPush::InvalidSubscription, WebPush::ExpiredSubscription
    # 無効な購読は非アクティブにする
    update(active: false)
    false
  rescue => e
    Rails.logger.error "WebPush送信エラー: #{e.message}"
    false
  end
end
