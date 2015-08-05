class ChangeQueuesVideosName < ActiveRecord::Migration
  def change
    rename_table :queues_videos, :queue_videos
  end
end
