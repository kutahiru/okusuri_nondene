class RewardTarget
  include ActiveModel::Model
  include ActiveModel::Attributes

  USER_TYPES = {
    medication_taker: "medication_taker", # 服薬者
    family_watcher: "family_watcher" # 見守り家族
  }.freeze

  attribute :medication_group_id, :integer
  attribute :group_name, :string
  attribute :reward_name, :string
  attribute :user_id, :integer
  attribute :uid, :string
  attribute :user_type, :string
  attribute :reward_date_time, :datetime

  def medication_taker?
    user_type == "medication_taker"
  end

  def family_watcher?
    user_type == "family_watcher"
  end
end
