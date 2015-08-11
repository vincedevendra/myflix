require 'bcrypt'

class User < ActiveRecord::Base
  has_secure_password 
  has_many :reviews
  has_many :queue_items, -> { order("position") }

  validates :email, presence: true, uniqueness: true
  validates :full_name, presence: true

  def has_video_in_queue?(video)
    !!video_queue_item(video)
  end

  def video_queue_item(video)
    queue_items.find_by(video: video)
  end

  def normalize_queue_item_positions
    queue_items.each_with_index do |queue_item, index|
      queue_item.update(position: index+1)
    end
  end

  def position_of_new_queue_item
    queue_items.count + 1
  end
end