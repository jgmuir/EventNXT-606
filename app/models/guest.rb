class Guest < ApplicationRecord
    belongs_to :event
    belongs_to :user, foreign_key: :added_by

    has_many :guest_seat_tickets
    has_many :guest_referral_rewards
    has_many :seats, through: :guest_seat_tickets, dependent: :destroy
    has_many :referral_rewards, through: :guest_referral_rewards, dependent: :destroy

    attribute :booked, :boolean, default: false
    
    validates :email, presence: true, uniqueness: true
    validates :booked, inclusion: [true, false, nil]
    validates :added_by, presence: true
    validates :invite_expiration, expiration: true
    validates :referral_expiration, expiration: true
end