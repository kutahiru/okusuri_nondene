FactoryBot.define do
  factory :medication_group_user do
    association :user
    association :medication_group
    user_type { "medication_taker" }

    trait :family_watcher do
      user_type { "family_watcher" }
    end
  end
end
