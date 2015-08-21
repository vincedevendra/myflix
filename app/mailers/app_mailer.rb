class AppMailer < ActionMailer::Base
  def send_welcome_email(user)
    @user = user
    mail from: 'info@myflix.com', to: user.email, subject: 'Welcome to MyFlix!'
  end

  def send_password_reset_email(user, token)
    @token = token
    mail from: 'support@myflix.com', to: user.email, subject: "Instructions to Reset Your Password"
  end
end