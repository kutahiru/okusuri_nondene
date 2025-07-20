class RewardHistory < ApplicationRecord
  belongs_to :medication_group

  validates :reward_name, presence: true, length: { maximum: 255 }
  validates :reward_date, presence: true

  # 指定月のスコープ
  scope :for_month, ->(date = Date.current) {
    where(reward_date: date.beginning_of_month..date.end_of_month)
  }
end
