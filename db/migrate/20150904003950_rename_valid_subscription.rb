class RenameValidSubscription < ActiveRecord::Migration
  def change
    rename_column :users, :valid_subscription?, :subscription_status
  end
end
