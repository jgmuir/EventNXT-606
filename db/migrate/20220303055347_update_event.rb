class UpdateEvent < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :address, :string, null: false
    add_column :events, :datetime, :datetime, null: false
    add_column :events, :description, :string
    add_column :events, :last_modified, :datetime, null: false
    remove_column :events, :date
    remove_column :events, :total_seats
    remove_column :events, :box_office_customers
    remove_column :events, :total_seats_box_office
    remove_column :events, :total_seats_guest
    remove_column :events, :balance
  end
end
