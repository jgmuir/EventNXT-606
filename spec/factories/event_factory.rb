FactoryBot.define do
  factory :event do
    title { Faker::Lorem.word }
    date { Faker::Date.forward }
  end
end