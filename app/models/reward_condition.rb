class RewardCondition < ApplicationRecord
  belongs_to :medication_group
  has_many :reward_histories, foreign_key: :medication_group_id,
           primary_key: :medication_group_id, dependent: :destroy

  validates :reward_name, presence: true, length: { maximum: 255 }
  validates :condition_type, presence: true, inclusion: { in: %w[0 1 2] }
  validates :target_weekday, presence: true, if: :weekly_condition?
  validates :target_value, presence: true, numericality: { greater_than: 0 }, if: :consecutive_days_condition?

  enum condition_type: { no_reward: '0', weekly: '1', consecutive_days: '2' }, _prefix: :condition

end
