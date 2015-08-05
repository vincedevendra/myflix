class ChangeQueueVideosColumnName < ActiveRecord::Migration
  def change
    rename_column :queue_videos, :queue_id, :queue_item_id
  end
end
