class UpdateDatabase < ActiveRecord::Migration[6.1]
  def change
    create_table :seats, force: :cascade do |t|
      t.references :event, null: false, foreign_key: true
      t.string :category, null: false
      t.integer :total_count
      t.float :price
    end

    create_table :guests, force: :cascade do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :email, null: false
      t.string :first_name
      t.string :last_name
      t.string :affiliation
      t.string :type
      t.boolean :booked
      t.datetime :invite_expiration
      t.datetime :referral_expiration
      t.datetime :invited_at
      t.datetime :emailed_at
    end
    rename_column :guests, :user_id, :added_by
    add_index :guests, [:email, :event_id], unique: true
    
    create_table :referral_rewards, force: :cascade do |t|
      t.references :event, null: false, foreign_key: true
      t.string :reward
      t.integer :min_count, default: 0
    end
    
    create_table :guest_seat_tickets do |t|
      t.references :guest, null: false, foreign_key: true
      t.references :seat, null: false, foreign_key: true
      t.integer :committed
      t.integer :allotted, default: 0
    end
    add_index :guest_seat_tickets, [:guest_id, :seat_id], unique: true
    
    create_table :guest_referral_rewards do |t|
      t.references :guest, null: false, foreign_key: true
      t.references :referral_reward, null: false, foreign_key: true
      t.integer :count, default: 0
    end

    add_reference :events, :user, foreign_key: true
  end
end
