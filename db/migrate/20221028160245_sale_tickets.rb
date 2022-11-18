class SaleTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :sale_tickets, force: :cascade do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :seat_section
      t.integer :tickets
    end
  end
end
