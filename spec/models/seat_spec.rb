require 'rails_helper'

RSpec.describe Seat, type: :model do
  it "fails without category" do
    seat = build(:seat, category: nil)
    expect(seat).to_not be_valid
  end

  it "fails if total count is negative" do
    seat = build(:seat, total_count: Faker::Number.digit)
    expect(seat).to be_valid

    seat = build(:seat, total_count: -Faker::Number.non_zero_digit)
    expect(seat).to_not be_valid
  end

  it "fails if total_count not a number" do
    seat = build(:seat, total_count: Faker::Lorem.word)
    expect(seat).to_not be_valid
  end

  it "validates if total_count is nil" do
    seat = build(:seat, total_count: nil)
    expect(seat).to be_valid
  end

  it "fails if price is negative" do
    seat = build(:seat, price: Faker::Number.digit)
    expect(seat).to be_valid

    seat = build(:seat, price: -Faker::Number.non_zero_digit)
    expect(seat).to_not be_valid
  end

  it "fails if price not a number" do
    seat = build(:seat, price: Faker::Lorem.word)
    expect(seat).to_not be_valid
  end

  it "validates if price is nil" do
    seat = build(:seat, price: nil)
    expect(seat).to be_valid
  end

  it "has a valid model with at least category" do
    seat = build(:seat, total_count: nil, price: nil)
    expect(seat).to be_valid
  end
end
