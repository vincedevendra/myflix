class AddUserIdToQueues < ActiveRecord::Migration
  def change
    add_column :queues, :user_id, :integer
  end
end
