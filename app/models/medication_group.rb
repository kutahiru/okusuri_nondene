class MedicationGroup < ApplicationRecord
  validates :group_name, presence: true, length: { maximum: 20 }

  has_many :medication_group_users, dependent: :destroy
  has_many :users, through: :medication_group_users
  has_many :medication_schedules, dependent: :destroy
  has_one  :reward_condition, dependent: :destroy
  has_many :reward_histories, dependent: :destroy
  has_many :medication_group_invitations, dependent: :destroy
  has_many :medication_managements, dependent: :destroy

  # グループの新規登録、ユーザーも服薬者として追加
  def self.create_group_with_user!(medication_group_update_param, user_id)
    transaction do
      group = create!(medication_group_update_param)
      group.medication_group_users.create!(
        user_id: user_id,
        user_type: "medication_taker"
      )

      includes(medication_group_users: :user).find(group.id)
    end
  end
end
