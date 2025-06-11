class MedicationGroupUser < ApplicationRecord
  belongs_to :medication_group
  belongs_to :user

  validates :user_type, presence: true, inclusion: { in: [0, 1] }
  validates :user_id, uniqueness: { scope: :medication_group_id }

  enum user_type: { medication_taker: 0, family_watcher: 1 }, _prefix: :user
end
