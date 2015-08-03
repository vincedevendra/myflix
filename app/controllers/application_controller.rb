class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :require_user

  helper_method [:logged_in?, :current_user]

  def logged_in?
    !!current_user
  end

  def current_user
    @current_user ||= User.find(session[:current_user_id]) if session[:current_user_id]
  end

  def require_user
    redirect_to splash_path unless logged_in?
  end
end
