class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user
      if user.authenticate(params[:password])
        session[:current_user_id] = user.id
        redirect_to home_path
      end
    end
    flash[:danger] = "Please check your username and password and try again."
    render 'new'
  end
end