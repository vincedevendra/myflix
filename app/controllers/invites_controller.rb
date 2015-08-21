class InvitesController < ApplicationController
  def create
    invitee = User.find_by(email: params[:email])
    
    if invitee
      flash[:info] = "It looks like #{params[:name]} is already a member!"
      redirect_to new_invite_path
    else
      flash[:info] = "An invitation email has been sent to #{params[:email]}."
      redirect_to root_path
    end
  end
end