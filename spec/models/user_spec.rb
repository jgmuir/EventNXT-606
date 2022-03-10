require 'rails_helper'

RSpec.describe User, type: :model do
  it 'fails without email' do
    user = build(:user, email: '')
    expect(user).to_not be_valid
  end

  it 'fails without password' do
    user = build(:user, password: '')
    expect(user).to_not be_valid
  end

  it 'has valid model with all email, password, and dates' do
    user = build(:user)
    expect(user).to be_valid
  end
end
