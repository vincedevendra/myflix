require 'spec_helper'

describe InvitesController do
  describe "GET new" do
    it "sets @invite to a new invite" do
      get :new
      expect(assigns(:invite)).to be_a_new(Invite)
    end
  end

  describe "POST create" do
    let(:augustine) { Fabricate(:user) }
    subject { ActionMailer::Base.deliveries.last }
    before { set_current_user(augustine) }
    after { ActionMailer::Base.deliveries.clear }

    context "if the email does not belong to a myflix user" do
      context "when the invitation passes validations" do
        before { post :create, invite: Fabricate.attributes_for(:invite, email: 'bobs@youruncle.com') }
        
        it "creates a new invite" do
          expect(Invite.count).to eq(1)
        end

        it "sends an email to the email inputted" do
          expect(subject.to).to eq(['bobs@youruncle.com'])
        end

        it "contains a url with the invitation token" do
          expect(subject.body).to include(Invite.first.token)
        end

        it "sets an info message" do
          expect(flash[:info]).to be_present
        end

        it "redirects to the root_path" do
          expect(response).to redirect_to root_path
        end
      end

      context "when the invitation does not pass validations" do
        before { post :create, invite: { email: 'nil' } }

        it "sets @invite with errors" do
          expect(assigns(:invite)).to be_present
        end

        it "renders the 'new' template" do
          expect(response).to render_template 'new'
        end
      end
    end

    context "if the email belongs to a current user" do
      let(:betty) { Fabricate(:user)}

      before do
        post :create, invite: Fabricate.attributes_for(:invite, email: betty.email)
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
      let(:action) { post :create, invite: Fabricate.attributes_for(:invite) }
    end
  end
end