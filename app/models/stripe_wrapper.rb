module StripeWrapper
  class Charge
    attr_reader :status, :response

    def initialize(response, status)
      @response = response
      @status = status
    end

    def self.create(options={})
      begin
        response = Stripe::Charge.create(
          :amount => options[:amount],
          :currency => options[:currency] ||= "usd",
          :source => options[:token],
          :description => options[:description]
        )
        new(response, :success)
      rescue Stripe::CardError => e
        new(e, :error)
      end
    end

    def successful?
      status == :success
    end

    def error_message
      response.message
    end
  end

  def self.set_api_key
    Stripe.api_key = ENV.fetch('STRIPE_API_KEY')
  end
end
