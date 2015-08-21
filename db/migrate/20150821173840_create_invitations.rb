class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :email
      t.string :name
      t.string :token
      t.text :message
      t.timestamps
    end

    remove_column :users, :invitation_token
  end
end
