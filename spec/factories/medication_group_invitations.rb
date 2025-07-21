FactoryBot.define do
  factory :medication_group_invitation do
    association :medication_group
    association :user
    max_uses { 3 }
    used_count { 0 }
    expires_at { 3.days.from_now }

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :max_used do
      used_count { 3 }
    end

    trait :partially_used do
      used_count { 1 }
    end
  end
end
