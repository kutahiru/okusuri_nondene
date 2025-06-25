class MedicationHistory < ApplicationRecord
  belongs_to :user

  validates :medication_date, presence: true
  validates :drug_name, presence: true, length: { maximum: 255 }
  validates :completed_at, presence: true
end
