class AppMailer < ActionMailer::Base
  def send_welcome_email(user)
    @user = user
    mail from: 'info@myflix.com', to: recipient(user.email), subject: 'Welcome to MyFlix!'
  end

  def send_password_reset_email(user, token)
    @token = token
    mail from: 'support@myflix.com', to: recipient(user.email), subject: "Instructions to Reset Your Password"
  end

  def send_invitation_email(invite, user)
    @invite = invite
    mail from: 'info@myflix.com', to: recipient(invite.email), subject: "#{user.full_name} has invited you to try MyFlix!"
  end

  def send_failed_payment_email(user, failure_message)
    @failure_message = failure_message
    mail from: 'info@myflix.com', to: recipient(user.email), subject: "Your myflix payment didn't go through"
  end

  def send_non_payment_cancellation_email(user)
    mail from: 'info@myflix.com', to: recipient(user.email), subject: "Your myflix subscription has been cancelled."
  end

  private
    def recipient(address)
      Rails.env == 'staging' ? 'vincedevendra@gmail.com' : address
    end
end
