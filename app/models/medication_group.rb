class MedicationGroup < ApplicationRecord
  validates :group_name, presence: true, length: { maximum: 20 }

  has_many :medication_group_users, dependent: :destroy
  has_many :users, through: :medication_group_users
  has_many :medication_schedules, dependent: :destroy
  has_one  :reward_condition, dependent: :destroy
  has_many :reward_histories, dependent: :destroy
  has_many :medication_group_invitations, dependent: :destroy
  has_many :medication_managements, dependent: :destroy
end
