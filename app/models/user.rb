class User < ApplicationRecord
  has_one :guest
  has_many :events

  validates :email, presence: true, email: true
  validates :encrypted_password, presence: true
  # todo: updated_at > created_at
  validates :created_at, presence: true
  validates :updated_at, presence: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
