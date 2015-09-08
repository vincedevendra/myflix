class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :require_user
  before_action :require_valid_subscription

  helper_method [:logged_in?, :current_user]

  def logged_in?
    !!current_user
  end

  def current_user
    @current_user ||= User.find(session[:current_user_id]) if session[:current_user_id]
  end

  def require_user
    unless logged_in?
      flash[:danger] = "Please sign in or register."
      redirect_to welcome_path
    end
  end

  def redirect_when_logged_in
    if logged_in?
      flash[:warning] = "You are already signed in."
      redirect_to root_path
    end
  end

  def require_valid_subscription
    unless logged_in? && (current_user.valid_subscription? || current_user.admin?)
      flash[:danger] = "Your subscription has been cancelled.  Please update your credit card details to resubscribe to myflix."
      redirect_to account_details_path
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :full_name, :password, :password_confirmation)
    end
end
