class Review < ActiveRecord::Base
  belongs_to :user
  belongs_to :video
  validates_presence_of [:body, :rating, :user, :video]
  validates_numericality_of :rating, less_than_or_equal_to: 5, greater_than_or_equal_to: 1
end