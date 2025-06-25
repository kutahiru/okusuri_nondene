class MedicationGroupInvitation < ApplicationRecord
  belongs_to :medication_group
  belongs_to :user

  # 招待認証時の処理
  def accept_invitation!(user_id, user_type)
    transaction do
      # 服薬グループにユーザー追加
      medication_group_user = MedicationGroupUser.add_user_to_group!(medication_group.id, user_id, user_type)

      # 招待の使用回数を加算
      increment!(:used_count)

      medication_group_user
    end
  end

  # 署名付きIDを使って招待レコードを取得
  def self.find_by_token(token)
    find_signed(
      token,
      purpose: :medication_group_invitation
    )
  end

  # 招待が存在しない場合のみ新規に登録
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
