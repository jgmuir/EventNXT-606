class GuestReferralReward < ApplicationRecord
    belongs_to :guest
    belongs_to :referral_reward
    
    validates :guest_id, presence: true
    validates :referral_reward_id, presence: true
    validates :count, presence: true, numericality: {greater_than_or_equal_to: 0, only_integer: true}
end