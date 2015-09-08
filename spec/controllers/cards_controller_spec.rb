require 'spec_helper'

describe CardsController do
  describe 'post#create' do
    context "when the card creation is successful" do
      before do
        set_current_user
        card = double('card', successful?: true)
        allow(StripeWrapper::Card).to receive(:create).with(user: current_user, token: '11') { card }
        post :create, stripeToken: '11'
      end

      it 'flashes a success message' do
        expect(flash[:success]).to be_present
      end

      it "redirects to the account_details_path" do
        expect(response).to redirect_to new_card_path
      end
    end

    context "when the card creation is unsuccessful" do
      before do
        set_current_user
        card = double('card', successful?: false, error_message: 'declined')
        allow(StripeWrapper::Card).to receive(:create).with(user: current_user, token: '11') { card }
        post :create, stripeToken: '11'
      end

      it "flashes a danger message" do
        expect(flash[:danger]).to include('declined')
      end

      it "redirects to the account_details_path" do
        expect(response).to redirect_to new_card_path
      end
    end
  end
end
