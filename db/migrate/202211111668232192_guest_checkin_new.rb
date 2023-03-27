class GuestCheckinNew < ActiveRecord::Migration[7.0]
    def change
      add_column :guests, :perks, :string
      add_column :guests, :comments, :string
    end
  end