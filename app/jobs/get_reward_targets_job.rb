# 定期実行でreward_conditionsテーブルを元にご褒美対象を取得し以下の処理を行う
# ・ご褒美通知のジョブキューを作成する
# ・ご褒美履歴を作成する
class GetRewardTargetsJob < ApplicationJob
  sidekiq_options retry: false

  def perform
    # 通知対象を取得
    reward_targets = RewardDatabaseService.get_reward_data
    reward_targets.each do |target|
      # ご褒美履歴を作成
      RewardDatabaseService.insert_reward_history(target)

      # 全属性をハッシュに変更
      # ハッシュ経由でしか渡せないため
      target_hash = target.attributes

      # JOBキューに登録
      LineNotificationJob.set(wait_until: target.reward_date_time).perform_later(target_hash)
    end
  end
end
