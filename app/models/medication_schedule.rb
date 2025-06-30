class MedicationSchedule < ApplicationRecord
  belongs_to :medication_group
  has_many :schedule_drugs, dependent: :destroy
  has_many :medication_managements, dependent: :destroy

  validates :title, presence: true, length: { maximum: 20 }
  validates :medication_time, presence: true
  validates :reminder_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reminder_interval, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :family_notification_delay, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # 定数
  MAX_MEDICATION_SCHEDULE = 3

  # 最大数チェック
  def self.check_medication_schedule_maximum(medication_group_id)
    count = where(medication_group_id: medication_group_id)
      .count()

    if count >= MAX_MEDICATION_SCHEDULE
      "スケジュールは#{MAX_MEDICATION_SCHEDULE}つまで作成可能です"
    end
  end
end
