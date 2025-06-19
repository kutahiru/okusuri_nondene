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
end
