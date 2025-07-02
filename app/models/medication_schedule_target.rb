class MedicationScheduleTarget
  include ActiveModel::Model
  include ActiveModel::Attributes

  USER_TYPES = {
    medication_taker: "medication_taker", # 服薬者
    family_watcher: "family_watcher" # 見守り家族
  }.freeze

  attribute :medication_schedule_id, :integer
  attribute :medication_management_id, :integer
  attribute :schedule_title, :string
  attribute :medication_date_time, :datetime
  attribute :family_notification_date_time, :datetime
  attribute :user_id, :integer
  attribute :uid, :string
  attribute :user_type, :string
  attribute :medication_group_id, :integer
  attribute :group_name, :string

  def medication_taker?
    user_type == "medication_taker"
  end

  def family_watcher?
    user_type == "family_watcher"
  end
end
