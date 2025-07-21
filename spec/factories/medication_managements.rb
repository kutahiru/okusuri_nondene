FactoryBot.define do
  factory :medication_management do
    association :medication_schedule
    association :medication_group
    medication_date { Date.current }
    reminder_sent_count { 0 }
    is_taken { false }
    completed_at { nil }

    trait :taken do
      is_taken { true }
      completed_at { Time.current }
    end

    trait :with_reminders do
      reminder_sent_count { 2 }
    end
  end
end
