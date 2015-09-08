class ChangeNameSubscription < ActiveRecord::Migration
  def change
    rename_column :users, :subscription_status, :valid_subscription
  end
end
