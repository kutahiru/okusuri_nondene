class PushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  # プッシュ通知の購読を作成または更新（同じendpointなら更新）
  def create
    existing_subscription = find_existing_subscription

    if existing_subscription
      update_existing_subscription(existing_subscription)
    else
      create_new_subscription
    end
  rescue => e
    Rails.logger.error "PushSubscription作成エラー: #{e.message}"
    render json: {
      status: "error",
      message: "購読の保存に失敗しました"
    }, status: :internal_server_error
  end

  # プッシュ通知の購読を非アクティブ化（論理削除、active: false）
  def destroy
    subscription = current_user.push_subscriptions.find(params[:id])
    subscription.update(active: false)

    render json: { status: "unsubscribed" }
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: "error",
      message: "購読が見つかりません"
    }, status: :not_found
  end

  private

  # 現在のユーザーの購読から同じendpointを検索
  def find_existing_subscription
    current_user.push_subscriptions.find_by(
      endpoint: subscription_params[:endpoint]
    )
  end

  # 既存の購読情報を更新してJSONレスポンスを返す
  def update_existing_subscription(subscription)
    subscription.update(subscription_attributes)
    render json: { status: "updated", subscription: subscription }
  end

  # 新規購読を作成し、失敗時はバリデーションエラーを返す
  def create_new_subscription
    push_subscription = current_user.push_subscriptions.build(subscription_attributes)

    if push_subscription.save
      render json: { status: "created", subscription: push_subscription }
    else
      render json: {
        status: "error",
        errors: push_subscription.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # Web Push購読の属性をハッシュで構築
  def subscription_attributes
    {
      endpoint: subscription_params[:endpoint],
      p256dh: subscription_params[:keys][:p256dh],
      auth: subscription_params[:keys][:auth],
      user_agent: request.user_agent,
      active: true
    }
  end

  # Strong Parameters で許可された購読パラメータを取得
  def subscription_params
    @subscription_params ||= params.require(:subscription).permit(
      :endpoint,
      keys: [ :p256dh, :auth ]
    )
  end
end
