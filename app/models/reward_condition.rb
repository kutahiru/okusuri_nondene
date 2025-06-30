class RewardCondition < ApplicationRecord
  belongs_to :medication_group
  has_many :reward_histories, foreign_key: :medication_group_id,
           primary_key: :medication_group_id, dependent: :destroy

  validates :reward_name, presence: true, length: { maximum: 20 }
  validates :condition_type, presence: true
  validates :target_weekday, presence: true, if: :condition_weekly?
  validates :target_value, presence: true, numericality: { greater_than: 0 }, if: :condition_daily_streak?

  enum condition_type: { weekly: "weekly", daily_streak: "daily_streak" }, _prefix: :condition
end
