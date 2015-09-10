class AddValidSubscriptionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :valid_subscription?, :boolean
  end
end
