class ScheduleDrug < ApplicationRecord
  belongs_to :medication_schedule

  validates :drug_name, presence: true, length: { maximum: 255 }
end
