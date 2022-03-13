FactoryBot.define do
  factory :guest do
    sequence(:id)
    association :event
    association :user

    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    booked { [true, false].sample }
    invite_expiration { Faker::Date.forward }
    referral_expiration { Faker::Date.forward }
    invited_at { Time.new }
  end
end