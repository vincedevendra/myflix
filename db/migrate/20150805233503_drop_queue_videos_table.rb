class DropQueueVideosTable < ActiveRecord::Migration
  def change
    drop_table :queue_videos
  end
end
