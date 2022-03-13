require 'rails_helper'

RSpec.describe ReferralReward, type: :model do
  it 'fails when minimum count is negative' do
    ref = build(:referral_reward, min_count: -Faker::Number.non_zero_digit)
    expect(ref).to_not be_valid
  end

  it 'fails when reward is nil' do
    ref = build(:referral_reward, reward: nil)
    expect(ref).to_not be_valid
  end

  it 'has valid model with reward and minimum count' do
    ref = build(:referral_reward)
    expect(ref).to be_valid
  end
end
