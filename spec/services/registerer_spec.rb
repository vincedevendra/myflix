require 'spec_helper'

describe Registerer do
  describe '#register_user' do
    context "when user is valid" do
      let(:user) { User.new(Fabricate.attributes_for(:user)) }
      after { ActionMailer::Base.deliveries.clear }

      context "when card info is valid" do
        before do
          customer_creation = double('customer_creation', successful?: true, id: 'customer1')
          allow(StripeWrapper::Customer).to receive(:create) { customer_creation }
        end

        it "creates a new user object" do
          registerer = Registerer.new(user, '111')
          registerer.register_user
          expect(User.count).to eq(1)
        end

        it "subscribes the user" do
          registerer = Registerer.new(user, '111')
          expect(StripeWrapper::Customer).to receive(:create)
          registerer.register_user
        end

        it "sets the status of the registerer object to :success" do
          registerer = Registerer.new(user, '111')
          registerer.register_user
          expect(registerer.status).to eq (:success)
        end

        it "saves the stripe customer id on the user" do
          registerer = Registerer.new(user, '111')
          registerer.register_user
          expect(user.reload.stripe_customer_id).to eq('customer1')
        end

        context "email sending" do
          let(:subject) { ActionMailer::Base.deliveries.last }
          let(:registerer) { Registerer.new(user, '111') }
          before { registerer.register_user }

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
          let(:registerer) { Registerer.new(user, '111', invite) }
          before { registerer.register_user }

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
        let(:registerer) { Registerer.new(user, '111') }

        before do
          customer_creation = double('customer_creation', successful?: false)
          allow(customer_creation).to receive(:error_message) { 'The card was declined.' }
          allow(StripeWrapper::Customer).to receive(:create) { customer_creation }
          registerer.register_user
        end

        it "does not save the user object"  do
          expect(User.count).to eq(0)
        end

        it "does not send out an email" do
          expect(ActionMailer::Base.deliveries).to be_empty
        end

        it "does not set the status of the registerer object to :success" do
          expect(registerer.status).to be_nil
        end

        it "sets an error message on the registerer object" do
          expect(registerer.error_message).to eq('The card was declined.')
        end
      end
    end

    context "when user is invalid" do
      let(:user) { User.new(Fabricate.attributes_for(:user, email: ' ')) }
      let(:registerer) { Registerer.new(user, '111') }
      after { ActionMailer::Base.deliveries.clear }

      it "does not save the user object"  do
        registerer.register_user
        expect(User.count).to eq(0)
      end

      it "does not send out an email" do
        registerer.register_user
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it "does not create the customer" do
        expect(StripeWrapper::Customer).not_to receive(:create)
        registerer.register_user
      end

      it "does not set the status of the registerer object to :success" do
        registerer = Registerer.new(user, '111')
        registerer.register_user
        expect(registerer.status).to be_nil
      end
    end
  end

  describe "#successful?" do
    let(:user) { Fabricate(:user) }
    let(:registerer) { Registerer.new(user, '111')}

    it "returns true if the status of registerer object is :success" do
      registerer.status = :success
      expect(registerer.successful?).to be_truthy
    end

    it "returns false if the status of registerer is not set" do
      expect(registerer.successful?).to be_falsy
    end
  end
end
