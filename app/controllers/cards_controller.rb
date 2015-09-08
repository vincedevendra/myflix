class CardsController < ApplicationController
  skip_before_action :require_valid_subscription

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

    redirect_to new_card_path
  end
end
