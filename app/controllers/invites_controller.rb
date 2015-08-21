class InvitesController < ApplicationController
  def new
    @invite = Invite.new
  end

  def create
    invitee = User.find_by(email: params[:invite][:email])
    @invite = Invite.new(invite_params.merge!(user_id: current_user.id))
    
    if invitee
      flash[:info] = "It looks like #{invitee.full_name} is already a member!"
      redirect_to new_invite_path
    elsif @invite.save
      @invite.generate_token!
      AppMailer.send_invitation_email(@invite, current_user).deliver
      flash[:info] = "An invitation email has been sent to #{@invite.email}."
      redirect_to root_path
    else
      render 'new'
    end
  end

  private
    def invite_params
      params.require(:invite).permit(:email, :message, :name)
    end
end