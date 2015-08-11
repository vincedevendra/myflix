class QueueItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  validates_presence_of :user
  validates_numericality_of :position, greater_than: 0, only_integer: true
  
  delegate :category, to: :video
  delegate :title, to: :video, prefix: :video
  delegate :title, to: :category, prefix: :category

  def user_rating
    user_review.rating if user_review
  end

  def user_rating=(new_rating)
    unless new_rating.blank?
      if user_review
        user_review.update!(skip_body: true, rating: new_rating)
      else
        Review.create!(skip_body: true, user: user, video: video, rating: new_rating)
      end
    end
  end

  def move_to_top_and_fix_positions
    user.queue_items.select { |qi| qi.position < position }.each do |qi| 
      qi.update(position: (qi.position + 1))
    end
    update(position: 1)
  end

  def user_review
    @user_review ||= user.reviews.find_by(video: video)
  end
end