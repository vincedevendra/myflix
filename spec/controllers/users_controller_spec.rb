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
  end

  describe 'POST create' do
    context "user input clears validations" do
      before do
        post :create, user: Fabricate.attributes_for(:user, full_name: "Pete")
      end

      it "creates a new user object" do
        expect(User.count).to eq(1)
      end

      context "email sending" do
        let(:subject) { ActionMailer::Base.deliveries.last }
        after { ActionMailer::Base.deliveries.clear }

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

      it "redirects to sign_in_path" do
        expect(response).to redirect_to sign_in_path
      end
    end

    context "user input fails validations" do
      before do 
        post :create, user: { email: '' }
      end
      after { ActionMailer::Base.deliveries.clear }

      it "does not save the user object" do
        expect(User.count).to eq(0)
      end

      it "renders :new template" do
        expect(response).to render_template 'new'
      end

      it "does not send out an email" do
        expect(ActionMailer::Base.deliveries).to be_empty
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