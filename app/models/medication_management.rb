class MedicationManagement < ApplicationRecord
  belongs_to :medication_schedule
  has_one :reward_history, dependent: :nullify

  validates :medication_date, presence: true
  validates :reminder_sent_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :completed_at_presence_when_taken

  enum is_taken: { not_taken: false, taken: true }, _prefix: :medication

  before_save :set_completed_at_on_taken_change
end
