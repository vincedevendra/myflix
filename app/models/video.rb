class Video < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :category
  has_many :reviews, -> { order('created_at DESC') }
  has_many :queue_videos
  has_many :queue_items, through: :queue_videos
  mount_uploader :small_cover, SmallCoverUploader
  mount_uploader :large_cover, LargeCoverUploader

  validates_presence_of :title, :description

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

  def as_indexed_json(options={})
    as_json(only: ['title', 'description'])
  end

  def self.search(query)
    __elasticsearch__.search (
      {
        query: {
          multi_match: {
            query: query,
            operator: 'and',
            fields: ['title', 'description']
          }
        }
      }
    )
  end
end
