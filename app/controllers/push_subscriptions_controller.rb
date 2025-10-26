class PushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

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

  def find_existing_subscription
    current_user.push_subscriptions.find_by(
      endpoint: subscription_params[:endpoint]
    )
  end

  def update_existing_subscription(subscription)
    subscription.update(subscription_attributes)
    render json: { status: "updated", subscription: subscription }
  end

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

  def subscription_attributes
    {
      endpoint: subscription_params[:endpoint],
      p256dh: subscription_params[:keys][:p256dh],
      auth: subscription_params[:keys][:auth],
      user_agent: request.user_agent,
      active: true
    }
  end

  def subscription_params
    @subscription_params ||= params.require(:subscription).permit(
      :endpoint,
      keys: [ :p256dh, :auth ]
    )
  end
end
