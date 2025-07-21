FactoryBot.define do
  factory :user do
    user_name { "テストユーザー" }
    provider { "line" }
    sequence(:uid) { |n| "line_uid_#{n}" }
    description_read { false }
  end
end
