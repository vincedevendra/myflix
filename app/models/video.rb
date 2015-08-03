class Video < ActiveRecord::Base
  belongs_to :category

  validates_presence_of :title, :description
  #validates :small_cover_url, presence: true
  #validates :large_cover_url, presence: true

  def self.search_by_title(search_terms)
    return [] if search_terms.blank?
    self.where('title ILIKE ?', '%' + search_terms + '%').order(created_at: :desc)
  end
end