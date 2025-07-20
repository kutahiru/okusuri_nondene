class MedicationManagement < ApplicationRecord
  belongs_to :medication_schedule
  belongs_to :medication_group

  validates :medication_date, presence: true
  validates :reminder_sent_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  enum :is_taken, { not_taken: false, taken: true }, prefix: :medication

  # 指定月のスコープ（汎用的）
  scope :for_month, ->(date = Date.current) {
    where(medication_date: date.beginning_of_month..date.end_of_month)
  }

  # ご褒美履歴のjoin
  scope :with_rewards, -> {
    joins(
      "LEFT JOIN reward_histories ON " \
      "reward_histories.medication_group_id = medication_managements.medication_group_id " \
      "AND reward_histories.reward_date = medication_managements.medication_date"
    ).select("medication_managements.*, reward_histories.reward_name")
  }

  # 服薬済に変更する
  def self.update_is_taken!(id)
    medication_management = MedicationManagement.find(id)

    # 既に服薬済なら終了
    return if medication_management.medication_taken?

    medication_management.update!(
      is_taken: true,
      completed_at: Time.current
    )

    # 服薬済に変更された場合、見守り家族に通知
    LineNotificationService.family_watcher_medication_taken_send_line_message(medication_management, medication_management.medication_group.group_name)
  end
end
