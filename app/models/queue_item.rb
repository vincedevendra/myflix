class QueueItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  validates_presence_of :user
  validates_uniqueness_of :position, scope: :user_id
  validates_uniqueness_of :video_id, scope: :user_id

  delegate :category, to: :video
  delegate :title, to: :video, prefix: :video
  delegate :title, to: :category, prefix: :category

  def user_rating
    r = user.reviews.find_by(video: self.video)
    r.rating if r
  end

  def update_queue_position_numbers
    position_number = position
    user.queue_items.select { |qi| qi.position > position_number }.each do |qi| 
      qi.update(position: (qi.position - 1))
    end
  end
end