class BoxofficeHeaders < ActiveRecord::Migration[7.0]
  def change
    create_table :boxoffice_headers, force: :cascade do |t|
      t.references :event, null: false, foreign_key: true
      t.integer :header_row
      t.integer :first_name
      t.integer :last_name
      t.integer :email
      t.integer :seat_section
      t.integer :tickets
    end
  end
end
