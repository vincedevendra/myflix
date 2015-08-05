require 'bcrypt'

class User < ActiveRecord::Base
  has_secure_password 
  has_many :reviews
  has_one :queue_item

  validates :email, presence: true, uniqueness: true
  validates :full_name, presence: true
end