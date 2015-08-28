class UsersController < ApplicationController
  skip_before_action :require_user, except: [:show]
  before_action :redirect_when_logged_in, except: [:show]

  def new
    @user = User.new
    handle_invite_behavior_new
  end

  def create
    @user = User.new(user_params)
    if @user.valid?
      charge = handle_stripe_charge
      if charge.successful?
        @user.save
        handle_invite_behavior_create
        AppMailer.send_welcome_email(@user).deliver
        flash[:success] = "You have successfully registered! Please sign in below."
        redirect_to sign_in_path
      else
        flash.now[:danger] = charge.error_message
        render 'new'
      end
    else
      flash.now[:danger] = "Please fix the following errors:"
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

    def handle_invite_behavior_create
      invite = find_invite
      if invite
        inviter = User.find(invite.user_id)
        @user.follows(inviter)
        inviter.follows(@user)

        invite.update_attribute(:token, nil)
      end
    end

    def find_invite
      Invite.find_by(token: params[:invite_token])
    end

    def handle_stripe_charge
      token = params[:stripeToken]
      charge = StripeWrapper::Charge.create(
        amount: 999,
        token: token,
        description: "1st month of service for #{@user.full_name}"
      )
    end
end
