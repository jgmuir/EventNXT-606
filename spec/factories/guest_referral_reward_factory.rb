FactoryBot.define do
  factory :guest_referral_reward do
    sequence(:id)
    association :guest
    association :referral_reward

    count { Faker::Number.digit }
  end
end