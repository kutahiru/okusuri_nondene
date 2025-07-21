FactoryBot.define do
  factory :medication_schedule do
    association :medication_group
    title { "朝の薬" }
    medication_time { "08:00" }
    reminder_count { 3 }
    reminder_interval { 30 }
    family_notification_delay { 60 }
  end
end
