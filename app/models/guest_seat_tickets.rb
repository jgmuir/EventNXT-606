class GuestSeatTicket < ApplicationRecord
    belongs_to :guests
    belongs_to :seats
    
    validates :guests_id, presence: true
    validates :seats_id, presence: true
    validates :committed, numericality: {greater_than_or_equal_to: 0, only_integer: true, allow_nil: true}
    validates :allotted, numericality: {greater_than: 1, only_integer: true}
end