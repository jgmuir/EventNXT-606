class UpdateEvent < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :address, :string
    add_column :events, :datetime, :datetime
    add_column :events, :description, :string
    add_column :events, :lastmodified, :datetime
    remove_column :events, :date
    remove_column :events, :total_seats
    remove_column :events, :box_office_customers
    remove_column :events, :total_seats_box_office
    remove_column :events, :total_seats_guest
    remove_column :events, :balance
    remove_column :events, :seat_category
  end
end
