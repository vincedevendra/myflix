require 'spec_helper'

describe StripeWrapper::Charge do
  describe ".create", :vcr do
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

      it "succesfully charges the card" do
        expect(subject.status).to eq(:success)
      end

      describe "successful?" do
        it "returns true if the charge is successful" do
          expect(subject.successful?).to eq(true)
        end
      end
    end

    context "when card is invalid" do
      let(:card_number) { '4000000000000002'}

      it "does not charge the card" do
        expect(subject.status).to eq(:error)
      end

      it "contains an error message" do
        expect(subject.response.message).to be_present
      end

      describe "successful?" do
        it "returns true if the charge is successful" do
          expect(subject.successful?).to eq(false)
        end
      end

      describe "error_message" do
        it "should return an error message when a charge is declined" do
          expect(subject.error_message).to be_an_instance_of(String)
        end
      end
    end
  end
end
