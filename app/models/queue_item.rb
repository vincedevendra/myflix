class QueueItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  validates_presence_of :user
  
  delegate :category, to: :video
  delegate :title, to: :video, prefix: :video
  delegate :title, to: :category, prefix: :category

  def user_rating
    review = user.reviews.find_by(video: video)
    review.rating if review
  end

  def update_queue_position_numbers
    position_number = position
    user.queue_items.select { |qi| qi.position > position_number }.each do |qi| 
      qi.update(position: (qi.position - 1))
    end
  end
end