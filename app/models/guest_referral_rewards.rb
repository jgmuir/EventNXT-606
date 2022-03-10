class GuestReferralRewards < ApplicationRecord
    belongs_to :guests
    belongs_to :referral_rewards
    
    validates :guests_id, presence: true
    validates :referral_rewards_id, presence: true
    validates :count, presence: true, numericality: {greater_than_or_equal_to: 0}
end