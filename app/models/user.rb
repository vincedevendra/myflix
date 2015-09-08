require 'bcrypt'

class User < ActiveRecord::Base
  include Tokenable

  has_secure_password
  has_many :reviews, -> { order("created_at DESC") }
  has_many :queue_items, -> { order("position") }
  has_many :followings, -> { order(created_at: :desc) }
  has_many :followeds, class_name: "Following", foreign_key: :followee_id
  has_many :followees, through: :followings
  has_many :followers, through: :followeds, source: :user

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
  validates :full_name, presence: true

  before_create :default_values

  def default_values
    self.delinquent = false
    self.valid_subscription = true
  end

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

  def follows?(user)
    followees.include?(user)
  end

  def following_with(user)
    Following.find_by(user: self, followee: user)
  end

  def follows(followee)
    Following.create(user: self, followee: followee)
  end

  def has_valid_subscription?
    valid_subscription
  end
end
