class Video < ActiveRecord::Base
  belongs_to :category
  has_many :reviews, -> { order('created_at DESC') }
  has_many :queue_videos
  has_many :queue_items, through: :queue_videos

  validates_presence_of :title, :description
  #validates :small_cover_url, presence: true
  #validates :large_cover_url, presence: true

  def self.search_by_title(search_terms)
    return [] if search_terms.blank?
    where('title ILIKE ?', '%' + search_terms + '%').order(created_at: :desc)
  end

  def average_rating
    (reviews.select('rating').map{ |r| r.rating.to_f }.inject('+') / reviews.count).round(1)
  end

  def belongs_to_user_queue?(user)
    !!user_queue_item(user)
  end

  def user_queue_item(user)
    QueueItem.find_by(user: user, video: self)
  end
end