class RenameColumnInQueueItems < ActiveRecord::Migration
  def change
    rename_column :queue_items, :queue_video_id, :video_id
  end
end
