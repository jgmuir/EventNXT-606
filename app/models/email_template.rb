class EmailTemplate < ApplicationRecord
    belongs_to :event
    belongs_to :user
    has_many_attached :attachments, dependent: :purge_later

    attribute :is_html, :boolean, default: false
end