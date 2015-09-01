require 'spec_helper'

describe Registration do
  describe '#register_user' do
    context "when user is valid" do
      let(:user) { User.new(Fabricate.attributes_for(:user)) }
      after { ActionMailer::Base.deliveries.clear }

      context "when card info is valid" do
        before do
          charge = double('charge', successful?: true)
          allow(StripeWrapper::Charge).to receive(:create) { charge }
        end

        it "creates a new user object" do
          registration = Registration.new(user, '111')
          registration.register_user
          expect(User.count).to eq(1)
        end

        it "returns 'success'" do
          registration = Registration.new(user, '111')
          expect(registration.register_user).to eq("success")
        end

        context "email sending" do
          let(:subject) { ActionMailer::Base.deliveries.last }
          let(:registration) { Registration.new(user, '111') }
          before { registration.register_user }

          it "sends an email" do
            expect(subject).to be_truthy
          end

          it "sends an email to the correct user" do
            expect(subject.to).to eq([user.email])
          end

          it "sends an email with the correct content" do
            expect(subject.body).to include("Welcome to MyFlix")
          end
        end

        context "when the user has followed an invitation link" do
          let!(:alice) { Fabricate(:user) }
          let(:invite) { Fabricate(:invite, user_id: alice.id) }
          let(:registration) { Registration.new(user, '111', invite) }
          before { registration.register_user }

          it "sets a following with the new user as the followee" do
            expect(alice.reload.followees).to include(user)
          end

          it "sets a following with the inviter as the followee" do
            expect(user.reload.followees).to include(alice)
          end

          it "clears the invitation token" do
            expect(invite.reload.token).to be_nil
          end
        end
      end

      context "when card info is invalid" do
        let(:registration) { Registration.new(user, '111') }
        before do
          charge = double('charge', successful?: false)
          allow(charge).to receive(:error_message) { 'The card was declined.' }
          allow(StripeWrapper::Charge).to receive(:create) { charge }
        end

        it "does not save the user object"  do
          registration.register_user
          expect(User.count).to eq(0)
        end

        it "does not send out an email" do
          registration.register_user
          expect(ActionMailer::Base.deliveries).to be_empty
        end

        it "returns 'charge_failed'" do
          expect(registration.register_user).to eq("failure")
        end
      end
    end

    context "when user is invalid" do
      let(:user) { User.new(Fabricate.attributes_for(:user, email: ' ')) }
      let(:registration) { Registration.new(user, '111') }
      after { ActionMailer::Base.deliveries.clear }

      it "does not save the user object"  do
        registration.register_user
        expect(User.count).to eq(0)
      end

      it "does not send out an email" do
        registration.register_user
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it "does not charge the card" do
        expect(StripeWrapper::Charge).not_to receive(:create)
        registration.register_user
      end

      it "returns 'failure'" do
        expect(registration.register_user).to eq("failure")
      end
    end
  end
end
