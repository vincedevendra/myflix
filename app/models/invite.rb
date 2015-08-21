class Invite < ActiveRecord::Base
  include Tokenable
  validates_presence_of [:email, :name, :message]
end