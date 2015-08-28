
require 'spec_helper'

describe UsersController do
  describe 'GET new' do
    it "sets @user to a new record when no signed in user" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    it "redirects to root_path for signed in user" do
      set_current_user
      get :new
      expect(response).to redirect_to root_path
    end

    context "when the user has followed an invitation link" do
      let(:invite) { Fabricate(:invite) }
      before { get :new, invite_token: invite.token }

      it "sets @invite_name from the token in the params" do
        expect(assigns(:invite_name)).to eq(invite.reload.name)
      end

      it "sets @invite_email from the token in the params" do
        expect(assigns(:invite_email)).to eq(invite.reload.email)
      end

      it "sets @invite_token from the token in the params" do
        expect(assigns(:invite_token)).to eq(invite.reload.token)
      end
    end
  end

  describe 'POST create' do
    context "when user input clears validations" do
      after { ActionMailer::Base.deliveries.clear }

      context "when card info is valid" do
        before do
          charge = double('charge', successful?: true)
          allow(StripeWrapper::Charge).to receive(:create) { charge }
        end

        it "creates a new user object" do
          post :create, user: Fabricate.attributes_for(:user, full_name: "Pete"), stripeToken: '111'
          expect(User.count).to eq(1)
        end

        context "email sending" do
          let(:subject) { ActionMailer::Base.deliveries.last }
          before { post :create, user: Fabricate.attributes_for(:user, full_name: "Pete"), stripeToken: '111' }

          it "sends an email" do
            expect(subject).to be_truthy
          end

          it "sends an email to the correct user" do
            user = User.find_by(full_name: "Pete")
            expect(subject.to).to eq([user.email])
          end

          it "sends an email with the correct content" do
            expect(subject.body).to include("Welcome to MyFlix")
          end
        end

        context "when the user has followed an invitation link" do
          let!(:alice) { Fabricate(:user) }
          let(:invite) { Fabricate(:invite, user_id: alice.id) }
          before { post :create, user: Fabricate.attributes_for(:user, full_name: "Pete"), invite_token: invite.token, stripeToken: '111' }

          it "sets a following with the new user as the followee" do
            pete = User.find_by(full_name: "Pete")
            expect(alice.reload.followees).to include(pete)
          end

          it "sets a following with the inviter as the followee" do
            pete = User.find_by(full_name: "Pete")
            expect(pete.reload.followees).to include(alice)
          end

          it "clears the invitation token" do
            expect(invite.reload.token).to be_nil
          end
        end

        it "redirects to sign_in_path" do
          post :create, user: Fabricate.attributes_for(:user), stripeToken: '111'
          expect(response).to redirect_to sign_in_path
        end
      end

      context "when card info is invalid" do
        before do
          charge = double('charge', successful?: false)
          allow(charge).to receive(:error_message) { 'The card was declined.' }
          allow(StripeWrapper::Charge).to receive(:create) { charge }
          post :create, user: Fabricate.attributes_for(:user), stripeToken: '111'
        end

        it "does not save the user object"  do
          expect(User.count).to eq(0)
        end

        it "sets a flash[:danger] message" do
          expect(flash[:danger]).to eq('The card was declined.')
        end

        it "renders :new template" do
          expect(response).to render_template 'new'
        end

        it "does not send out an email" do
          expect(ActionMailer::Base.deliveries).to be_empty
        end
      end
    end

    context "when user input fails validations" do
      after { ActionMailer::Base.deliveries.clear }

      it "does not save the user object"  do
        post :create, user: { email: '' }, stripeToken: '111'
        expect(User.count).to eq(0)
      end

      it "renders :new template" do
        post :create, user: { email: '' }, stripeToken: '111'
        expect(response).to render_template 'new'
      end

      it "does not send out an email" do
        post :create, user: { email: '' }, stripeToken: '111'
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it "does not charge the card" do
        expect(StripeWrapper::Charge).not_to receive(:create)
        post :create, user: { email: '' }, stripeToken: '111'
      end

      it "sets a flash[:danger] message" do
        post :create, user: { email: '' }, stripeToken: '111'
        expect(flash[:danger]).to include("Please fix")
      end
    end
  end

  describe "GET show" do
    let(:video) { Fabricate(:video) }
    let(:video_2) { Fabricate(:video) }
    let(:user) { Fabricate(:user) }
    let!(:queue_item) { Fabricate(:queue_item, user: user, video: video, position: 1) }
    let!(:queue_item_2) { Fabricate(:queue_item, user: user, video: video_2, position: 2) }
    let!(:review) { Fabricate(:review, user: user, created_at: 2.days.ago) }
    let!(:review_2) { Fabricate(:review, user: user, created_at: 1.days.ago) }

    before { set_current_user }

    it "assigns @user from the params" do
      get :show, id: user.id
      expect(assigns(:user)).to eq(user)
    end

    it "assigns @queue_items to those associated with the user" do
      get :show, id: user.id
      expect(assigns(:queue_items)).to eq([queue_item, queue_item_2])
    end

    it "assigns @reviews to the reviews the user has written" do
      get :show, id: user.id
      expect(assigns(:reviews)).to match_array([review, review_2])
    end

    it "orders @reviews by order created" do
      get :show, id: user.id
      expect(assigns(:reviews)).to eq([review_2, review])
    end

    it_behaves_like "no_current_user_redirect" do
      let(:action) { get :show, id: 3 }
    end
  end
end
