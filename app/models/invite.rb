class Invite < ActiveRecord::Base
  include Tokenable

  after_create :generate_token!
  validates_presence_of [:email, :name, :message]
end