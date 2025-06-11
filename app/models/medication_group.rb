class MedicationGroup < ApplicationRecord
  validates :group_name, presence: true, length: { maximum: 255 }

  has_many :medication_group_users, dependent: :destroy
  has_many :users, through: :medication_group_users
  has_many :medication_schedules, dependent: :destroy
  has_many :reward_conditions, dependent: :destroy
  has_many :reward_histories, dependent: :destroy
end
