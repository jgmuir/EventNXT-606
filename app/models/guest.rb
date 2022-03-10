class Guest < ApplicationRecord
    belongs_to :events
    belongs_to :users, foreign_key: :added_by
    has_many :seats, through: :guest_seat_tickets, dependent: :destroy
    has_many :referral_rewards, through: :guest_referral_rewards, dependent: :destroy
    
    validates :email, presence: true, uniqueness: true
    validates :booked, presence: true
    validates :invite_expiration, expiration: true
    validates :referral_expiration, expiration: true
end