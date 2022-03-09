class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :title
      t.string :date
     
      t.integer :total_seats
      t.string :box_office_customers
      t.integer :total_seats_box_office
      t.integer :total_seats_guest
      t.integer :balance
      # add image thing here
    end
  end
end
