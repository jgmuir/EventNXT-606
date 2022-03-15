require 'rails_helper'

RSpec.describe Event, type: :model do
  it "fails without title" do
    event = build(:event, title: nil)
    expect(event).to_not be_valid
  end

  it "fails without address" do
    event = build(:event, address: nil)
    expect(event).to_not be_valid
  end

  it "fails without date" do
    event = build(:event, datetime: nil)
    expect(event).to_not be_valid
  end

  it "fails if date is in the past" do
    event = build(:event, datetime: Faker::Date.backward)
    expect(event).to_not be_valid
  end

  it "has a valid model with title, address, and datetime fields" do
    event = build(:event)
    expect(event).to be_valid
  end
end
