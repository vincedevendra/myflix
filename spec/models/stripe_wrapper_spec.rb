require 'spec_helper'

describe StripeWrapper::Charge do
  let(:token) { generate_stripe_token }

  before { StripeWrapper.set_api_key }

  subject do
    StripeWrapper::Charge.create(
      amount: 999,
      token: token,
      description: 'hey'
    )
  end

  context "when card is valid" do
    let(:card_number) { '4242424242424242' }

    it "succesfully charges the card", :vcr do
      expect(subject).to be_successful
    end
  end

  context "when card is invalid", :vcr do
    let(:card_number) { '4000000000000002'}

    it "does not charge the card" do
      expect(subject).not_to be_successful
    end

    it "contains an error message", :vcr do
      expect(subject.error_message).to be_present
    end
  end
end
