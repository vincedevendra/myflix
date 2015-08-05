class QueueItem < ActiveRecord::Base
  belongs_to :user
  has_many :queue_videos, -> { order("created_at DESC") }
  has_many :videos, through: :queue_videos

  validates :user, presence: true, uniqueness: true
end