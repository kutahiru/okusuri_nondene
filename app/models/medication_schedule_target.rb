class MedicationScheduleTarget
  include ActiveModel::Model
  include ActiveModel::Attributes
  include UserTypeEnumerable

  attribute :medication_schedule_id, :integer
  attribute :medication_management_id, :integer
  attribute :schedule_title, :string
  attribute :medication_date_time, :datetime
  attribute :family_notification_date_time, :datetime
  attribute :user_id, :integer
  attribute :uid, :string
  attribute :user_type, :integer
end
