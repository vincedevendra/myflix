class UsersController < ApplicationController
  skip_before_action :require_user, only: [:new, :create, :splash]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to root_path
    else 
      render 'new'
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :full_name, :password, :password_confirmation)
    end
end