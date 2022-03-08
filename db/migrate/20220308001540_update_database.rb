class UpdateDatabase < ActiveRecord::Migration[6.1]
  def change
    add_column :seating_types, :Name, :string
    add_column :seating_types, :MaxSeats, :integer
    add_column :seating_types, :Price, :integer
    remove_column :seating_types, :box_office_seat_count
    remove_column :seating_types, :balance_seats
    remove_column :seating_types, :box_office_seat_count
    remove_column :seating_types, :vip_seats_count
    
    add_column :guests, :InvitationExpiration, :Date
    add_column :guests, :ReferralExpiration, :Date
    add_column :guests, :LastEmailed, :Date
    remove_column :guests, :seat_category
    remove_column :guests, :max_seats_num
    
    create_table :ReferralReward do |t|
      t.string :Rewards
      t.integer :MinReferrals
    end
    
    create_table :Guest_SeatCategory do |t|
    t.intger :CommittedSeats
    t.integer :MaxPossibleSeats
    t.bigint "guest_id"
    t.bigint "seat_category_id"
    
    end
    
    create_table :Guest_ReferralReward do |t|
      t.string :guesttoken
      t.integer :Referrals
      t.bigint "guest_id"
      t.bigint "referral_id"
   end
    add_foreign_key :Guest_ReferralReward, :guests, column: :guest_id, primary_key: :id
    add_foreign_key :Guest_ReferralReward, :ReferralReward, column: :referral_id, primary_key: :id
    add_foreign_key :Guest_SeatCategory, :guests, column: :guest_id, primary_key: :id
    add_foreign_key :Guest_SeatCategory, :SeatCategory, column: :guest_id, primary_key: :id
    add_foreign_key :ReferralReward, :events, column: :event_id, primary_key: :id
    add_foreign_key :SeatCategory, :events, column: :event_id, primary_key: :seat_category_id
  end
end
