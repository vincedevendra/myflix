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
      customer_creation = create_stripe_customer(stripe_token)
      if customer_creation.successful?
        user.stripe_customer_id = customer_creation.id
        user.save
        handle_invite_behavior_create(invite)
        AppMailer.send_welcome_email(user).deliver
        self.status = :success
        self
      else
        self.error_message = customer_creation.error_message
        self
      end
    end
    self
  end

  def successful?
    status == :success
  end

  private
  def create_stripe_customer(stripe_token)
    StripeWrapper::Customer.create(
      token: stripe_token,
      email: user.email
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
