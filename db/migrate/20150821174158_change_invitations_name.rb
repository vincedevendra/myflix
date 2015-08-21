class ChangeInvitationsName < ActiveRecord::Migration
  def change
    rename_table :invitations, :invites
  end
end
