class Video < ActiveRecord::Base
  belongs_to :category
  has_many :reviews, -> { order('created_at DESC') }

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
end