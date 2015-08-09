require 'bcrypt'

class User < ActiveRecord::Base
  has_secure_password 
  has_many :reviews
  has_many :queue_items

  validates :email, presence: true, uniqueness: true
  validates :full_name, presence: true

  def has_video_in_queue?(video)
    !!video_queue_item(video)
  end

  def video_queue_item(video)
    queue_items.find_by(video: video)
  end
end