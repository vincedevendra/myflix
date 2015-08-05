class CreateQueuesVideos < ActiveRecord::Migration
  def change
    create_table :queues_videos do |t|
      t.integer :queue_id
      t.integer :video_id
      t.timestamps
    end
  end
end
