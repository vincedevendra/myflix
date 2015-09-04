require 'spec_helper'

describe StripeWrapper::Customer do
  describe ".create", :vcr do
    let(:token) { generate_stripe_token }

    subject(:customer_creation) do
      StripeWrapper::Customer.create(
        token: token,
        email: 'foo@bar.org'
      )
    end

    context "when card is valid" do
      let(:card_number) { '4242424242424242' }

      it "succesfully creates the customer" do
        expect(customer_creation).to be_successful
      end

      describe "#id" do
        it "returns the customer id" do
          expect(customer_creation.id).to be_an_instance_of(String)
        end
      end
    end

    context "when card is invalid" do
      let(:card_number) { '4000000000000002'}

      it "does not create the customer" do
        expect(customer_creation).not_to be_successful
      end

      it "contains an error message" do
        expect(customer_creation.response.message).to be_an_instance_of(String)
      end

      describe "error_message" do
        it "should return an error message when a charge is declined" do
          expect(customer_creation.error_message).to be_an_instance_of(String)
        end
      end
    end
  end
end
