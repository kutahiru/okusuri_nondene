class MedicationGroupUser < ApplicationRecord
  include EnumHelp

  belongs_to :medication_group
  belongs_to :user

  enum user_type: {
    medication_taker: "medication_taker",
    family_watcher: "family_watcher"
  }

  validates :user_type, presence: true
  validates :user_id, uniqueness: { scope: :medication_group_id }
  validate :validate_user_group_limit
  validate :validate_user_limit_in_group


  # medication_takerのみ同一グループに1つまでの制約
  validates :user_type, uniqueness: {
    scope: :medication_group_id,
    message: "は同じグループ内で重複できません"
  }, if: :medication_taker?

  # 定数
  MAX_GROUPS_PER_USER = 3
  MAX_USERS_PER_GROUP  = 4

  # 服薬グループにユーザー追加
  def self.add_user_to_group!(medication_group_id, user_id, user_type)
    # 服薬者は一人の制限があるため、服薬者が選択された場合は既存の服薬者を見守り家族に変更
    if user_type == "medication_taker"
      update_family_watcher_in_group!(medication_group_id)
    end

    # 服薬グループユーザー作成
    create!(
      medication_group_id: medication_group_id,
      user_id: user_id,
      user_type: user_type
    )
  end

  # グループ内の服薬者を見守り家族に更新
  def self.update_family_watcher_in_group!(medication_group_id)
    where(medication_group_id: medication_group_id, user_type: "medication_taker")
    .update_all(user_type: "family_watcher")
  end

  # 指定したグループユーザーを服薬者に更新
  def self.update_medication_taker!(medication_group_user_id)
    find(medication_group_user_id).update!(user_type: "medication_taker")
  end

  # グループ内の服薬者を変更（トランザクション付き）
  def self.update_medication_taker_in_group!(group_id, selected_user_id)
    transaction do
      update_family_watcher_in_group!(group_id)
      update_medication_taker!(selected_user_id)
    end
  end

  # 参加可能なグループ数のチェック
  def validate_user_group_limit
    count= MedicationGroupUser.where(user_id: user_id)
      .where.not(id: id)
      .count()

    if count >= MAX_GROUPS_PER_USER
      errors.add(:base, "ユーザーが参加できるグループは#{MAX_GROUPS_PER_USER}つまでです。")
    end
  end

  # 1グループに参加可能なユーザー数のチェック
  def validate_user_limit_in_group
    count= MedicationGroupUser.where(medication_group_id: medication_group_id)
      .where.not(id: id)
      .count()

    if count >= MAX_USERS_PER_GROUP
      errors.add(:base, "1グループにユーザーは#{MAX_GROUPS_PER_USER}人までです。")
    end
  end
end
