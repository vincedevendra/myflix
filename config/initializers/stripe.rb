StripeWrapper.set_api_key

StripeEvent.configure do |events|
  events.subscribe "customer.subscription.deleted" do |event|
    user = User.find_by(stripe_customer_id: event.data.object.customer)
    user.update_attribute(:valid_subscription, false)
    AppMailer.send_non_payment_cancellation_email(user).deliver
  end

  events.subscribe "charge.failed" do |event|
    user = User.find_by(stripe_customer_id: event.data.object.customer)
    user.update_attribute(:delinquent, true)
    failure_message = event.data.object.failure_message
    AppMailer.send_failed_payment_email(user, failure_message).deliver
  end

  events.subscribe 'charge.succeeded' do |event|
    user = User.find_by(stripe_customer_id: event.data.object.source.customer)
    amount = event.data.object.amount
    id = event.data.object.id
    Payment.create(user: user, amount: amount, token: id)
  end
end
