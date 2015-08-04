require 'spec_helper'

describe UsersController do
  describe 'GET new' do

    it "sets @user to a new record when no signed in user" do
      get :new
      expect(assigns(:user)).to be_instance_of(User)
      expect(assigns(:user)).to be_new_record
    end

    it "redirects to root_path for signed in user" do
      session[:current_user_id] = Fabricate(:user).id
      get :new
      expect(response).to redirect_to root_path
    end

    describe 'POST create' do
      context "user input clears validations" do
        before do
          post :create, user: Fabricate.attributes_for(:user)
        end

        it "creates a new user object" do
          expect(User.count).to eq(1)
        end

        it "redirects to sign_in_path" do
          expect(response).to redirect_to sign_in_path
        end
      end

      context "user input fails validations" do
        before do 
          post :create, user: { email: '' }
        end

        it "does not save the user object" do
          expect(User.count).to eq(0)
        end

        it "renders :new template" do
          expect(response).to render_template 'new'
        end
      end
    end
  end
end