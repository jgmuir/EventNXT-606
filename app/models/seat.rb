class SeatingType < ApplicationRecord
  belongs_to :event
  validates :seat_category, presence: true
  validates :event_id, presence: true
  validates :total_seat_count, presence: true
end
