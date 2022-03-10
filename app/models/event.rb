class Event < ApplicationRecord
    belongs_to :users
    has_many :guests, dependent: :destroy
    has_many :seats, dependent: :destroy
    has_many :referral_rewards, dependent: :destroy
    
    require 'roo'
    def self.import(file)
      # Import only the first worksheet, where the first cell is: title - date
      # CSV.foreach(file.path, headers: true) do |row|
      #     guest = find_by(uid: row["uid"]) || new
      #     guest.attributes = row.to_hash
      #     guest.save!
      # end
      workbook = Roo::Spreadsheet.open(file.path)
      worksheets = workbook.sheets
      worksheet = worksheets[0]
      
      # parse worksheet: each worksheet includes all customer info of one event on one day
      title = workbook.cell(1,1)
      # title = first_cell[0][0..-2]
      # date = first_cell[1][1..-1]
      
      # read the xlsx file -> process the customer info into one string object box_office_customers
      box_office_customers = []
      workbook.sheet(worksheet).each_row_streaming(pad_cells: true) do |row|
        box_office_customers.append(row.map{ |cell| cell.value if cell}.join('#cell#'))
      end
      # puts(box_office_customers.inspect)
      box_office_customers = box_office_customers[1..-3]
      total_seats_box_office = box_office_customers.count() - 1
      box_office_customers = box_office_customers.join('#row#')
      
      for event in Event.all
        if event.title == title
          # Update the box office spreadsheet of an existing (event, date)
          event.update({:box_office_customers => box_office_customers})
          return event
        end
      end
      
      # Create a new (event, date) in the database: preset some variables (can be updated)
      total_seats = 500
      total_seats_guest = 0
      balance = total_seats - total_seats_box_office - total_seats_guest
      return Event.create!({:title => title, :date => "", :total_seats => total_seats, :box_office_customers => box_office_customers, 
          :total_seats_box_office => total_seats_box_office, :total_seats_guest => 0, :balance => balance})
    end
end
