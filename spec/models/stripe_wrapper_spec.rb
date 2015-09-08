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

describe StripeWrapper::Card do
  describe ".default_card(user)", :vcr do
    let(:user) { Fabricate(:user, stripe_customer_id: generate_stripe_customer_id) }

    it "retrieves the customer's default card", :vcr do
      expect(StripeWrapper::Card.default(user).last4).to eq('4242')
    end
  end

  describe ".update_current_card(options={})" do
  end

  describe ".create(options={})", :vcr do
    let(:user) { Fabricate(:user, stripe_customer_id: generate_stripe_customer_id) }

    context "when card is valid" do
      let(:card_number) { '4012888888881881' }
      let(:token) { generate_stripe_token }

      it "successfully creates a new card" do
        card_creation = StripeWrapper::Card.create(user: user, token: token)
        expect(card_creation).to be_successful
      end

      it "deletes the customer's old card" do
        card_creation = StripeWrapper::Card.create(user: user, token: token)
        customer = StripeWrapper::Customer.retrieve(user)
        expect(customer.sources.total_count).to eq(1)
      end

      it "sets the new card as the user's default card", :vcr do
        StripeWrapper::Card.create(user: user, token: token)
        customer = StripeWrapper::Customer.retrieve(user)
        card = StripeWrapper::Card.default(user)
        expect(card.last4).to eq('1881')
      end
    end

    context "when card is invalid" do
      let(:card_number) { '4000000000000002' }
      let(:token) { generate_stripe_token }

      it "does not successfully create new card" do
        card_creation = StripeWrapper::Card.create(user: user, token: token)
        expect(card_creation).not_to be_successful
      end

      it "keeps the user's current default card" do
        StripeWrapper::Card.create(user: user, token: token)
        customer = StripeWrapper::Customer.retrieve(user)
        card = StripeWrapper::Card.default(user)
        expect(card.last4).to eq('4242')
      end

      it "sets an error message" do
        card_creation = StripeWrapper::Card.create(user: user, token: token)
        expect(card_creation.error_message).to include('declined')
      end
    end
  end
end
