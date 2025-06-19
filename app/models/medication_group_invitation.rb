class MedicationGroupInvitation < ApplicationRecord
  belongs_to :medication_group
  belongs_to :user

  # 存在しない場合のみ新規に登録
  def self.find_or_create_active_invitation(medication_group_id, user_id)
    active_invitation = where(
      medication_group_id: medication_group_id,
      user_id: user_id
      )
      .where("expires_at > ?", Time.current)
      .where("used_count < max_uses")
      .first

    return active_invitation if active_invitation

    create!(
      medication_group_id: medication_group_id,
      user_id: user_id,
      max_uses: 3,
      expires_at: 3.days.from_now
    )
  end
end
