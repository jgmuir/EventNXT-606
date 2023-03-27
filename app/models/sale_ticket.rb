class SaleTicket < ApplicationRecord
    belongs_to :event
    belongs_to :user, foreign_key: :added_by
  
    def full_name
      "#{first_name} #{last_name}"
    end
end