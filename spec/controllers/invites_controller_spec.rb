require 'spec_helper'

describe InvitesController do
  describe "POST create" do
    let(:augustine) { Fabricate(:user) }
    subject { ActionMailer::Base.deliveries.last }
    before { set_current_user(augustine) }
    after { ActionMailer::Base.deliveries.clear }

    context "if the email does not belong to a myflix user" do
      context "if the user does not have a invitation token" do
        it "generates one" do
          post :create, email: 'bobs@youruncle.com', name: "Bob", message: "Hey, Bob."
          expect(augustine.invitation_token).to be_present
        end
      end

      context "if the user already has an invitation token" do
        it "does not change it" do
          augustine.update_attribute(:invitation_token, 'boop')
          post :create, email: 'bobs@youruncle.com', name: "Bob", message: "Hey, Bob."
          expect(augustine.reload.invitation_token).to eql('boop')
        end
      end

      it "sends an email to the email inputted" do
        post :create, email: 'bobs@youruncle.com', name: "Bob", message: "Hey, Bob."
        expect(subject.to).to eq(['bobs@youruncle.com'])
      end

      it "contains a url with the inviter's token" do
        post :create, email: 'bobs@youruncle.com', name: "Bob", message: "Hey, Bob."
        expect(subject.body).to include(augustine.inviter_token)
      end

      it "contains a url with the invitee's email as a param" do
        post :create, email: 'bobs@youruncle.com', name: "Bob", message: "Hey, Bob."
        expect(subject.body).to include('email=bobs@youruncle.com')
      end

      it "contains a url with the invitee's name as a param" do
        post :create, email: 'bobs@youruncle.com', name: "Bob", message: "Hey, Bob."
        expect(subject.body).to include('name=Bob')
      end

      it "sets an info message" do
        post :create, email: 'bobs@youruncle.com', name: "Bob", message: "Hey, Bob."
        expect(flash[:info]).to be_present
      end

      it "redirects to the root_path" do
        post :create, email: 'bobs@youruncle.com', name: "Bob", message: "Hey, Bob."
        expect(response).to redirect_to root_path
      end
    end

    context "if the email belongs to a current user" do
      let(:betty) { Fabricate(:user)}

      before do
        post :create, email: betty.email, name: betty.full_name, message: "Hey, Betts."
      end

      it "does not send an email" do
        expect(subject).to be_nil
      end

      it "sets an info message" do
        expect(flash[:info]).to be_present
      end

      it "redirect_to new_invite_path" do
        expect(response).to redirect_to new_invite_path
      end
    end

    it_behaves_like "no_current_user_redirect" do
      let(:action) { post :create, email: 'bobs@youruncle.com', name: "Bob", message: "Hey, Bob." }
    end
  end
end