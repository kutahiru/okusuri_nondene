class MedicationGroupUser < ApplicationRecord
  include UserTypeEnumerable

  belongs_to :medication_group
  belongs_to :user

  validates :user_type, presence: true, inclusion: { in: [ 0, 1 ] }
  validates :user_id, uniqueness: { scope: :medication_group_id }
end
