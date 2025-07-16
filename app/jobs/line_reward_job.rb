class LineRewardJob < ApplicationJob
  sidekiq_options retry: false

  def perform(target_attributes)
    # ハッシュからオブジェクトを再構築
    reward_target = RewardTarget.new(target_attributes)

    if reward_target.medication_taker?
      # 服薬者用の通知
      LineNotificationService.medication_taker_reward_send_line_message(reward_target.uid, reward_target.group_name, reward_target.reward_name)
    else
      # 見守り家族の通知
      LineNotificationService.family_watcher_reward_send_line_message(reward_target.uid, reward_target.group_name, reward_target.reward_name)
    end
  end
end
