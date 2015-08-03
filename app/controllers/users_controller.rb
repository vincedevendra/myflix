class UsersController < ApplicationController
  skip_before_action :require_user, only: [:new, :create]
  before_action :redirect_when_logged_in, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash.now[:success] = "You have succesfully registered! Please sign in below."
      redirect_to sign_in_path
    else 
      render 'new'
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :full_name, :password, :password_confirmation)
    end
end