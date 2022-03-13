FactoryBot.define do
  factory :guest_seat_ticket do
    sequence(:id)
    association :guest
    association :seat

    committed { Faker::Number.between(from: 0, to: allotted) }
    allotted { Faker::Number.non_zero_digit }
  end
end