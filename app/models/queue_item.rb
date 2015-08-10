class QueueItem < ActiveRecord::Base
  default_scope { order(:position) }

  belongs_to :user
  belongs_to :video

  validates_presence_of :user
  validates_numericality_of :position, greater_than: 0, only_integer: true
  
  delegate :category, to: :video
  delegate :title, to: :video, prefix: :video
  delegate :title, to: :category, prefix: :category

  def user_rating
    review = user.reviews.find_by(video: video)
    review.rating if review
  end
end