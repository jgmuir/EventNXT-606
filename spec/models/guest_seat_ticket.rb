require 'rails_helper'

RSpec.describe GuestSeatTicket, type: :model do
  it "fails if allotted is not positive" do
    guest_seat_ticket = build(:guest_seat_ticket, allotted: -Faker::Number.digit)
    expect(guest_seat_ticket).to_not be_valid
  end

  it "fails committed is more than allotted" do
    guest_seat_ticket = build(:guest_seat_ticket, committed: 2, allotted: 1)
    expect(guest_seat_ticket).to_not be_valid
  end

  it "validates when committed is nil" do
    guest_seat_ticket = build(:guest_seat_ticket, committed: nil)
    expect(guest_seat_ticket).to be_valid
  end

  it "has a valid model with guest and seat associations" do
    guest_seat_ticket = build(:guest_seat_ticket)
    expect(guest_seat_ticket).to be_valid
  end
end