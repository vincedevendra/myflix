class Following < ActiveRecord::Base
  belongs_to :user
  belongs_to :followee, class_name: "User"

  validates_uniqueness_of :followee_id, scope: [:user_id]
end