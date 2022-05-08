class GuestSeatTicket < ApplicationRecord
    belongs_to :guest
    belongs_to :seat
    
    attribute :allotted, :integer, default: 0
    
    validates :committed, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: :allotted, only_integer: true, allow_nil: true}
    validates :allotted, numericality: {greater_than_or_equal_to: 0, only_integer: true}
end