class MedicationManagement < ApplicationRecord
  belongs_to :medication_schedule
  belongs_to :medication_group
  has_one :reward_history, dependent: :nullify

  validates :medication_date, presence: true
  validates :reminder_sent_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  enum is_taken: { not_taken: false, taken: true }, _prefix: :medication

  # 指定月のスコープ（汎用的）
  scope :for_month, ->(date = Date.current) {
    where(medication_date: date.beginning_of_month..date.end_of_month)
  }

  # 服薬済に変更する
  def self.update_is_taken!(id)
    medication_management = MedicationManagement.find(id)
    medication_management.update!(
      is_taken: true,
      completed_at: Time.current
    )
  end
end
