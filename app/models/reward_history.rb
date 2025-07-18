class RewardHistory < ApplicationRecord
  belongs_to :medication_group

  validates :reward_name, presence: true, length: { maximum: 255 }
  validates :reward_date, presence: true
end
