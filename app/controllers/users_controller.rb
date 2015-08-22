class UsersController < ApplicationController
  skip_before_action :require_user, except: [:show]
  before_action :redirect_when_logged_in, except: [:show]

  def new
    @user = User.new
    handle_invite_behavior_new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      handle_invite_behavior_create
      AppMailer.send_welcome_email(@user).deliver
      flash[:success] = "You have succesfully registered! Please sign in below."
      redirect_to sign_in_path
    else 
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
    @queue_items = @user.queue_items
    @reviews = @user.reviews
  end

  private
    def handle_invite_behavior_new
      if params[:invite_token] 
        if Invite.find_by(token: params[:invite_token])
          invite = Invite.find_by(token: params[:invite_token])
          @invite_name = invite.name
          @invite_email = invite.email
          @invite_token = invite.token
        else
          redirect_to expired_link_path
          return
        end
      end
    end

    def handle_invite_behavior_create
      invite = Invite.find_by(token: params[:invite_token])
      if invite
        inviter = User.find(invite.user_id)
        Following.create(user: @user, followee: inviter)
        Following.create(user: inviter, followee: @user)

        invite.update_attribute(:token, nil)
      end
    end
end