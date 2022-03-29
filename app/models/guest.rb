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

  def self.to_csv
    guests = all
    CSV.generate(headers: true) do |csv|
      cols = [:last_name, :first_name, :email, :added_by, :affiliation, :type,
          :booked, :invited_at, :invite_expiration, :referral_expiration]
      csv << cols
      guests.each do |guest|
        user_email = guest.user.email
        gattr = guest.attributes.symbolize_keys.to_h
        gattr[:added_by] = guest.user.email
        gattr[:booked] = gattr[:booked] ? 'X' : ''
        csv << gattr.values_at(*cols)
      end
    end
  end
end