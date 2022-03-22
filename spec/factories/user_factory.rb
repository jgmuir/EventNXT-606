FactoryBot.define do
  factory :user do
    sequence(:id)
    email {Faker::Internet.email}
    password { Faker::Internet.password(min_length: 8) }
    created_at { Faker::Date.backward }
    updated_at { Faker::Date.forward }

    factory :user_with_events do
      transient do
        n_event { 3 }
      end

      after(:create) do |user, evaluator|
        create_list :event_all, evaluator.n_event, user: user
        user.reload
      end
    end
  end
end