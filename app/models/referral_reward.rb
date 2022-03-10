class ReferralReward < ApplicationRecord
    belongs_to :events
    has_many :guests, through: :guest_referral_rewards

    validate :reward, presence: true
end
