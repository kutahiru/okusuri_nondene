class LineRewardJob < ApplicationJob
  sidekiq_options retry: false

  def perform(target_attributes)
    # ハッシュからオブジェクトを再構築
    reward_target = RewardTarget.new(target_attributes)

    user = User.find_by(uid: reward_target.uid)

    if reward_target.medication_taker?
      # 服薬者用の通知
      # LINE通知
      LineNotificationService.medication_taker_reward_send_line_message(reward_target.uid, reward_target.group_name, reward_target.reward_name)

      # WebPush通知
      if user&.push_subscriptions&.active&.any?
        WebPushNotificationService.send_medication_taker_reward_notification(user, reward_target.group_name, reward_target.reward_name)
      end
    else
      # 見守り家族の通知
      # LINE通知
      LineNotificationService.family_watcher_reward_send_line_message(reward_target.uid, reward_target.group_name, reward_target.reward_name)

      # WebPush通知
      if user&.push_subscriptions&.active&.any?
        WebPushNotificationService.send_family_watcher_reward_notification(user, reward_target.group_name, reward_target.reward_name)
      end
    end
  end
end
