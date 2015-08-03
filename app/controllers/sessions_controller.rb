class SessionsController < ApplicationController
  skip_before_action :require_user
  before_action :redirect_when_logged_in, only: :new

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:current_user_id] = user.id
      flash[:success] = "You have successfully logged in."
      redirect_to root_path
    else
      flash[:danger] = "Please check your username and password and try again."
      render 'new'
    end
  end

  def destroy
    session[:current_user_id] = nil
    flash[:danger] = "You have signed out."
    redirect_to welcome_path
  end
end