class ChangeUsernameToEmailAddName < ActiveRecord::Migration
  def change
    rename_column :users, :username, :email
    add_column :users, :full_name, :string
  end
end
