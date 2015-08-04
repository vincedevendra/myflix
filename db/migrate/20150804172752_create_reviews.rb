class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.text :body
      t.integer :rating
      t.integer :user_id
      t.integer :video_id
    end
  end
end
