# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_bot_rails'
include FactoryBot::Syntax::Methods

Faker::Config.random = Random.new(42)

N_USERS_WITH_EVENTS  = 3
EVENTS_PER_USER      = 3
GUESTS_PER_EVENT     = 10
SEATS_PER_EVENT      = 3
REWARDS_PER_EVENT    = 3

create :user, email: Rails.application.credentials.admin[:email], password: Rails.application.credentials.admin[:password],
  created_at: Time.now, updated_at: Time.now

users = create_list :user, N_USERS_WITH_EVENTS
users.each { |user|
  events = create_list :event, EVENTS_PER_USER, user: user
  events.each { |event|
    guests = create_list :guest, GUESTS_PER_EVENT, event: event
    seats = create_list :seat, SEATS_PER_EVENT, event: event
    referral_rewards = create_list :referral_reward, REWARDS_PER_EVENT, event: event

    guests.product(seats).each { |guest, seat| create :guest_seat_ticket, guest: guest, seat: seat} 
    guests.product(referral_rewards).each { |guest, reward| create :guest_referral_reward, guest: guest, referral_reward: reward }
  }
}
