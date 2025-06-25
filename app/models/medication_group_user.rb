class MedicationGroupUser < ApplicationRecord
  # include UserTypeEnumerable

  belongs_to :medication_group
  belongs_to :user

  enum :user_type, {
    medication_taker: 0,
    family_watcher: 1
  }

  validates :user_type, presence: true
  validates :user_id, uniqueness: { scope: :medication_group_id }

  # 服薬グループにユーザー追加
  def self.add_user_to_group!(medication_group_id, user_id, user_type)
    # 服薬者は一人の制限があるため、服薬者が選択された場合は既存の服薬者を見守り家族に変更
    if user_type == user_types[:medication_taker]
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
    where(medication_group_id: medication_group_id, user_type: user_types[:medication_taker])
    .update_all(user_type: user_types[:family_watcher])
  end

  # 指定したグループユーザーを服薬者に更新
  def self.update_medication_taker!(medication_group_user_id)
    find(medication_group_user_id).update!(user_type: user_types[:medication_taker])
  end
end
