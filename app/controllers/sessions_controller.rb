class SessionsController < ApplicationController
  skip_before_action :require_user

  def create
    user = User.find_by(email: params[:email])
    if user
      if user.authenticate(params[:password])
        session[:current_user_id] = user.id
        redirect_to root_path
      end
    else
      flash[:danger] = "Please check your username and password and try again."
      render 'new'
    end
  end

  def destroy
    session[:current_user_id] = nil
    redirect_to splash_path
  end
end