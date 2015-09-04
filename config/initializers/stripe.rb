StripeWrapper.set_api_key

StripeEvent.configure do |events|
  events.subscribe 'charge.succeeded' do |event|
    user = User.find_by(stripe_customer_id: event.data.object.source.customer)
    amount = event.data.object.amount
    id = event.data.object.id
    Payment.create(user: user, amount: amount, token: id)
  end
end
