class MedicationSchedule < ApplicationRecord
  belongs_to :medication_group
  has_many :schedule_drugs, dependent: :destroy
  has_many :medication_managements, dependent: :destroy

  validates :medication_time, presence: true
  validates :reminder_count, presence: true, numericality: { greater_than: 0 }
  validates :reminder_interval, presence: true, numericality: { greater_than: 0 }
  validates :family_notification_delay, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
