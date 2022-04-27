class Seat < ApplicationRecord
  belongs_to :event

  has_many :guest_seat_tickets, dependent: :destroy
  has_many :guests, through: :guest_seat_tickets

  validates :category, presence: true
  validates :total_count, numericality: {greater_than_or_equal_to: 0, only_integer: true, allow_nil: true}
  validates :price, numericality: {greater_than_or_equal_to: 0, allow_nil: true}
end
