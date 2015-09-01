class UsersController < ApplicationController
  skip_before_action :require_user, except: [:show]
  before_action :redirect_when_logged_in, except: [:show]

  def new
    @user = User.new
    handle_invite_behavior_new
  end

  def create
    @user = User.new(user_params)
    registration = Registration.new(@user, params[:stripeToken], find_invite)

    case registration.register_user
    when "success"
      flash[:success] = "You have successfully registered! Please sign in below."
      redirect_to sign_in_path
    when "failure"
      error_message = registration.error_message
      flash.now[:danger] = error_message if error_message
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id]).decorate
    @queue_items = @user.queue_items
    @reviews = @user.reviews
  end

  private
    def handle_invite_behavior_new
      if params[:invite_token]
        invite = find_invite
        if invite
          @invite_name = invite.name
          @invite_email = invite.email
          @invite_token = invite.token
        else
          redirect_to invalid_link_path
        end
      end
    end

    def find_invite
      Invite.find_by(token: params[:invite_token])
    end
end
