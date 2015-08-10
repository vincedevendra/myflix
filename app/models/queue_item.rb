class QueueItem < ActiveRecord::Base
  default_scope { order(:position) }

  belongs_to :user
  belongs_to :video

  validates_presence_of :user
  validates_numericality_of :position, greater_than: 0
  
  delegate :category, to: :video
  delegate :title, to: :video, prefix: :video
  delegate :title, to: :category, prefix: :category

  def user_rating
    review = user.reviews.find_by(video: video)
    review.rating if review
  end

  def update_queue_positions_after_delete
    position_number = position
    user.queue_items.select { |qi| qi.position > position_number }.each do |qi| 
      qi.update(position: (qi.position - 1))
    end
  end

  def update_queue_positions_after_top
    position_number = position
    user.queue_items.select { |qi| qi.position < position_number }.each do |qi| 
      qi.update(position: (qi.position + 1))
    end
  end
end