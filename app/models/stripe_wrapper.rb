class StripeWrapper
  attr_reader :status, :response
  delegate :id, to: :@response
  delegate :message, to: :@response, prefix: :error

  def initialize(response, status)
    @response = response
    @status = status
  end

  def successful?
    status == :success
  end

  def self.set_api_key
    Stripe.api_key = ENV.fetch('STRIPE_API_KEY')
  end

  class Customer < StripeWrapper
    def self.create(options={})
      begin
        customer = Stripe::Customer.create(
          :source => options[:token],
          :plan => "myflix_monthly",
          :email => options[:email]
        )
        new(customer, :success)
      rescue Stripe::CardError => e
        new(e, :error)
      end
    end

    def self.retrieve(user)
      Stripe::Customer.retrieve(user.stripe_customer_id)
    end
  end

  class Card < StripeWrapper
    def self.default(user)
      if user.stripe_customer_id
        customer = StripeWrapper::Customer.retrieve(user)
        default_card_id = customer.default_source
        customer.sources.retrieve(default_card_id)
      end
    end

    def self.update_current_card(options={})
    end

    def self.create(options={})
      customer = StripeWrapper::Customer.retrieve(options[:user])
      old_card_id = customer.default_source
      begin
        card = customer.sources.create({:source => options[:token]})
        card.save
        customer.default_source = card.id
        customer.save
        customer.sources.retrieve(old_card_id).delete
        new(card, :success)
      rescue Stripe::CardError => e
        new(e, :error)
      end
    end
  end
end
