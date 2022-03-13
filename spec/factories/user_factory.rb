FactoryBot.define do
  factory :user do
    sequence(:id)
    email {Faker::Internet.email}
    password { Faker::Internet.password(min_length: 8) }
    created_at { Faker::Date.backward }
    updated_at { Faker::Date.forward }

    factory :user_with_events do
      transient do
        events_count {10}
      end

      after(:create) do |user, evaluator|
        create_list :event, evaluator.events_count, users: user
        user.reload
      end
    end
  end
end