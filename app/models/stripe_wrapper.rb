module StripeWrapper
  class Customer
    attr_reader :status, :response

    delegate :id, to: :@response
    delegate :message, to: :@response, prefix: :error

    def initialize(response, status)
      @response = response
      @status = status
    end

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

    def successful?
      status == :success
    end
  end

  def self.set_api_key
    Stripe.api_key = ENV.fetch('STRIPE_API_KEY')
  end
end
