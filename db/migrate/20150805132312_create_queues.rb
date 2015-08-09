class CreateQueues < ActiveRecord::Migration
  def change
    create_table :queues do |t|
      t.integer :queue_video_id
      t.timestamps
    end
  end
end
