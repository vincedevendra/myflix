class CardsController < ApplicationController
  skip_before_action :require_valid_subscription
  skip_before_action :flash_delinquent_warning

  def create
    token = params[:stripeToken]

    card_creation = StripeWrapper::Card.create(
      user: current_user,
      token: token
    )

    if card_creation.successful?
      flash[:success] = "Your payment method has been changed."
    else
      flash[:danger] = card_creation.error_message
    end

    reactivate_account

    redirect_to new_card_path
  end

  private
  def reactivate_account
    current_user.update_attribute(:valid_subscription, true) unless current_user.valid_subscription?
    current_user.update_attribute(:delinquent, false) if current_user.delinquent?
  end
end
