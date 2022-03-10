FactoryBot.define do
  factory :user do
    email {Faker::Internet.email}
    password { Faker::Internet.password(min_length: 8) }
    created_at { Faker::Date.backward }
    updated_at { Faker::Date.forward }

    factory :user_events do
      transient do
        events_count {3}
      end

      after(:create) do |user, evaluator|
        create_list(:event, evaluator.events_count, user: user)
        user.reload
      end
    end
  end
end