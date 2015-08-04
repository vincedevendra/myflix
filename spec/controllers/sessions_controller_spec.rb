require 'spec_helper'

describe SessionsController do
  describe 'GET new' do
    it "redirects to root_path if user is logged in" do
      session[:current_user_id] = Fabricate(:user).id
      get :new
      expect(response).to redirect_to root_path
    end
  end

  describe 'POST create' do
    let(:pete) { Fabricate(:user) }
    context "when user is authenticated" do
      before do
        post :create, email: pete.email, password: 'password'
      end
      
      it "signs in user" do
        expect(session[:current_user_id]).to eq pete.id
      end
      
      it "sets :success message" do
        expect(flash[:success]).not_to be_blank
      end

      it "redirects to root_path" do
        expect(response).to redirect_to root_path
      end
    end

    context "when user is not authenticated" do
      before do
        post :create, email: pete.email, password: 'skadoo'
      end
      
      it 'does not sign in user' do
        expect(session[:current_user_id]).to be_nil
      end
      
      it 'renders new' do
        expect(response).to render_template :new
      end

      it 'sets :danger message' do
        expect(flash[:danger]).not_to be_blank
      end
    end    
  end

  describe "GET destroy" do
    before { get :destroy }

    it "clears session[:current_user_id]" do
      expect(session[:current_user_id]).to be_nil
    end

    it "sets a :danger message" do
      expect(flash[:danger]).not_to be_blank
    end

    it "redirects to welcome_path" do
      expect(response).to redirect_to welcome_path
    end
  end
end