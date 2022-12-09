class CreateBoxofficeSeats < ActiveRecord::Migration[7.0]
  def change
    create_table :boxoffice_seats, force: :cascade do |t|
      t.references :event, null: false, foreign_key: true
      t.string :seat_section
      t.integer :booked_count
    end
  end
end
