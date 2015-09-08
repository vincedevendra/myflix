
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
    context "when user input is valid" do
      context "when credit card number is valid" do
        before do
          allow_any_instance_of(Registerer).to receive(:register_user) { double('registration', successful?: true) }
          post :create, user: Fabricate.attributes_for(:user), stripeToken: '111', invite_token: 'asdf'
        end

        it "flashes a success message" do
          expect(flash[:success]).to be_present
        end

        it "redirects to the sign in path" do
          expect(response).to redirect_to sign_in_path
        end
      end

      context "when credit card number is invalid" do
        before do
          registerer = double('registerer', successful?: false, error_message: 'card declined')
          allow_any_instance_of(Registerer).to receive(:register_user) { registerer }
          post :create, user: Fabricate.attributes_for(:user), stripeToken: '111', invite_token: 'asdf'
        end

        it "flashes a danger message" do
          expect(flash[:danger]).to be_present
        end

        it "renders the 'new' template" do
          expect(response).to render_template 'new'
        end
      end
    end

    context "when user input is invalid" do
      before do
        allow_any_instance_of(Registerer).to receive(:register_user) { double('registerer', successful?: false, error_message: nil) }
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '111', invite_token: 'asdf'
      end

      it "sets @user to display errors" do
        expect(assigns(:user)).to be_truthy
      end

      it "renders the 'new' template" do
        expect(response).to render_template 'new'
      end

      it "does not create a stripe customer" do
        expect(StripeWrapper::Customer).not_to receive(:create)
        post :create, user: { email: '' }, stripeToken: '111'
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

    it_behaves_like "no valid subscription redirect" do
      let(:action) { get :show, id: 3 }
    end
  end

  describe "GET edit" do
    it "sets @card as the current user's current form of payment" do
      card = double('card')
      allow(StripeWrapper::Card).to receive(:default).with(@user) { card }
      get :edit
      expect(assigns(:card)).to eq(card)
    end
  end

  describe "PATCH update" do
    let(:user) { Fabricate(:user, email: 'bar@foo.com') }
    before do
      card = double('card', last4: '1111', exp_month: '12', exp_year: '2015')
      allow(StripeWrapper::Card).to receive(:default) { card }
    end

    context "when user input passes validations" do
      before do
         patch :update, id: user.id, user: { email: 'foo@bar.com', password: 'foo', password_confirmation: 'foo' }
      end

      it "updates the customer info" do
        expect(user.reload.email).to eq("foo@bar.com")
      end

      it "flashes a success message" do
        expect(flash[:success]).to be_present
      end

      it "redirects to the account details path" do
        expect(response).to redirect_to account_details_path
      end
    end

    context "when user input fails validations" do
      before do
         patch :update, id: user.id, user: { email: 'foo@bar.com', password: 'foo', password_confirmation: 'bar' }
      end

      it "does not update the customer" do
        expect(user.reload.email).to eq("bar@foo.com")
      end

      it "renders the edit template" do
        expect(response).to render_template 'edit'
      end
    end
  end
end
