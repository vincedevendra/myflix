class AddCategoryidToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :category_id, :integer
    remove_column :categories, :video_id, :integer
  end
end
