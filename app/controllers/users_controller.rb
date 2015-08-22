class UsersController < ApplicationController
  skip_before_action :require_user, except: [:show]
  before_action :redirect_when_logged_in, except: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
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
end