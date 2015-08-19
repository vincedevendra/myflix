class FollowingsController < ApplicationController
  def index 
    @followings = current_user.followings
  end

  def create
    following = Following.new(user: current_user, followee: User.find(params[:followee_id]))
    
    if current_user == following.followee
      flash[:danger] = "You can't follow yourself."
    elsif following.save
      flash[:success] = "You are now following #{following.followee.full_name}."
    else
      flash[:danger] = "You are already following #{following.followee.full_name}."
    end

    redirect_to :back
  end

  def destroy
    following = Following.find(params[:id])

    if following.user == current_user
      following.destroy
      flash[:info] = "You are no longer following #{following.followee.full_name}."
    end

    redirect_to :back
  end
end