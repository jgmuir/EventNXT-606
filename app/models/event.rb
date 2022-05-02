class Event < ApplicationRecord
    belongs_to :user
    has_many :guests, dependent: :destroy
    has_many :seats, dependent: :destroy
    has_many :referral_rewards, dependent: :destroy
    has_many :email_templates, dependent: :destroy
    has_one_attached :image, dependent: :purge_later
    has_one_attached :box_office, dependent: :purge_later

    validates :title, presence: true
    validates :address, presence: true
    validates :datetime, presence: true, expiration: true
    validate :validate_image
    validate :validate_box_office
    
    private

    def validate_image
      return unless image.attached?
      return if image.blob.content_type.start_with? 'image/'
      errors.add(:image, 'needs to be an image')
    end

    def validate_box_office
      return unless box_office.attached?
      content_types = ['csv', 'tsv', 'xlsx', 'xlsm', 'ods'].map { |ext| Rack::Mime.mime_type ".#{ext}" }
      return if box_office.blob.content_type.start_with? *content_types
      errors.add(:box_office, 'needs to be ods, xlsx, xlsm, csv, or tsv')
    end
end
