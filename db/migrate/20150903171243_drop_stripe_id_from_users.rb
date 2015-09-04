class DropStripeIdFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :stripe_id
  end
end
