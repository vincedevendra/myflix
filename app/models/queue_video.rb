class QueueVideo < ActiveRecord::Base
  belongs_to :video
  belongs_to :queue_item
end