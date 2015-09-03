class Registerer
  attr_reader :user, :stripe_token, :invite
  attr_accessor :error_message, :status

  def initialize(user, stripe_token, invite=nil)
    @user = user
    @stripe_token = stripe_token
    @invite = invite
  end

  def register_user
    if user.valid?
      charge = handle_stripe_charge(stripe_token)
      if charge.successful?
        user.save
        handle_invite_behavior_create(invite)
        AppMailer.send_welcome_email(user).deliver
        self.status = :success
        self
      else
        self.error_message = charge.error_message
        self
      end
    end
    self
  end

  def successful?
    status == :success
  end

  private
  def handle_stripe_charge(stripe_token)
    charge = StripeWrapper::Charge.create(
      amount: 999,
      token: stripe_token,
      description: "1st month of service for #{@user.full_name}"
    )
  end

  def handle_invite_behavior_create(invite)
    if invite
      inviter = User.find(invite.user_id)
      user.follows(inviter)
      inviter.follows(user)

      invite.update_attribute(:token, nil)
    end
  end
end
