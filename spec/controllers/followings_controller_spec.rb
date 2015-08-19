require 'spec_helper'

describe FollowingsController do
  before { request.env['HTTP_REFERER'] = "from_whence_I_came" }

  describe "GET index" do
    let(:alice) { Fabricate(:user) }
    let(:billy) { Fabricate(:user) }
    let(:following) { Fabricate(:following, user: alice, followee: billy) }

    it "assigns @followings to current user's followings" do
      set_current_user(alice)
      get :index
      expect(assigns(:followings)).to eq([following])
    end

    it_behaves_like "no_current_user_redirect" do
      let(:action) { get :index }
  end

  describe "DELETE destroy" do
    let(:alice) { Fabricate(:user) }
    let(:billy) { Fabricate(:user) }
    let!(:following) { Fabricate(:following, user: alice, followee: billy) }

    context "when the current user is the one following" do
      before do 
        set_current_user(alice)
        delete :destroy, id: following.id
      end

      it "deletes the following" do
        expect(Following.count).to eq(0)
      end

      it "sets a flash[:info] message" do
        expect(flash[:info]).to be_present
      end
    end

    context "when the current user is not the one following" do
      before do
        set_current_user(billy)
        delete :destroy, id: following.id
      end

      it "does not delete the following" do
        expect(Following.count).to eq(1)
      end
    end

    it "redirects back" do
      set_current_user(alice)
      delete :destroy, id: following.id
      expect(response).to redirect_to "from_whence_I_came"
    end

    it_behaves_like "no_current_user_redirect" do
      let(:action) { delete :destroy, id: following.id }
    end
  end

  describe "POST create" do
    let(:albert) { Fabricate(:user) }
    let(:bertha) { Fabricate(:user) }

    context "if the current user isn't following the potential followee" do
      before do
        set_current_user(albert)
        post :create, followee_id: bertha.id
      end
      
      it "creates a new following" do
        expect(Following.count).to eq(1)
      end

      it "assigns the current user as the user" do
        expect(Following.first.user).to eq(albert)
      end

      it "assigns the followee from the params" do
        expect(Following.first.followee).to eq(bertha)
      end

      it "sets an success message" do
        expect(flash[:success]).to be_present
      end
    end

    context "if the current user already is following the potential followee" do
      it "does not create a new following" do
        set_current_user(albert)
        Fabricate(:following, user: albert, followee: bertha)
        post :create, followee_id: bertha.id
        expect(Following.count).to eq(1)
      end
    end

    context "if the current user is the potential followee" do
      it "does not create a new following" do
        set_current_user(albert)
        Fabricate(:following, user: albert, followee: albert)
        post :create, followee_id: albert.id
        expect(Following.count).to eq(0)
      end
    end

    it_behaves_like "no_current_user_redirect" do
      let(:action) { post :create, followee_id: 2 }
    end
  end
end