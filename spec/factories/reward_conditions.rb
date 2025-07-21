FactoryBot.define do
  factory :reward_condition do
    association :medication_group
    reward_name { "ご褒美" }
    condition_type { "weekly" }
    target_weekday { 1 } # Monday

    trait :daily_streak do
      condition_type { "daily_streak" }
      target_weekday { nil }
      target_value { 7 }
    end

    trait :weekly do
      condition_type { "weekly" }
      target_weekday { 0 } # Sunday
      target_value { nil }
    end
  end
end
