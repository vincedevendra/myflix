class UsersController < ApplicationController
  skip_before_action :require_user, except: [:show]
  skip_before_action :require_valid_subscription, except: [:show]
  before_action :redirect_when_logged_in, except: [:show, :edit, :update]
  before_action :set_user, only: [:show, :update]
  before_action :set_card, only: [:edit, :update]

  def new
    @user = User.new
    handle_invite_behavior_new
  end

  def create
    @user = User.new(user_params)
    registerer = Registerer.new(@user, params[:stripeToken], find_invite)
    registration = registerer.register_user

    if registration.successful?
      flash[:success] = "You have successfully registered! Please sign in below."
      redirect_to sign_in_path
    else
      error_message = registration.error_message
      flash.now[:danger] = error_message if error_message
      render 'new'
    end
  end

  def show
    @queue_items = @user.queue_items
    @reviews = @user.reviews
  end

  def edit
    @user = current_user
  end

  def update
    if @user.update(user_params)
      flash[:success] = "Your account information has been updated."
      redirect_to account_details_path
    else
      render 'edit'
    end
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

    def set_user
      @user = User.find(params[:id])
    end

    def set_card
      @card = StripeWrapper::Card.default(current_user)
    end
end
