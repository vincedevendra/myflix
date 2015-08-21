class ForgotPasswordsController < ApplicationController  
  skip_before_action :require_user

  def create
    user = User.find_by(email: params[:email])
    if user
      user.generate_token!
      token = user.token
      AppMailer.send_password_reset_email(user, token).deliver
      redirect_to confirm_password_reset_path
    else 
      flash.now[:danger] = "We're having trouble locating your account.  Please check your email and try again."
      render 'new'
    end
  end

  def edit
    @user =  find_user_by_params_token
    @token = params[:token]
    
    unless @user
      redirect_to invalid_token_path
    end
  end

  def update
    @user = find_user_by_params_token
    
    if @user && @user.update(user_params.merge!(token: nil))
      flash[:info] = "Your password has been reset."
      redirect_to sign_in_path
    else
      @token = params[:token]
      render 'edit'
    end
  end

  private
    def find_user_by_params_token
      User.find_by(token: params[:token])
    end
end