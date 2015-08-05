require 'spec_helper'

describe ReviewsController do
  let(:alpha) { Fabricate(:video) }

  describe "POST create" do
    it "redirects to welcome_path if no user is signed in" do
      post :create, review: Fabricate.attributes_for(:review), video_id: alpha.id
      expect(response).to redirect_to welcome_path
    end

    context "when user is signed in" do
      let(:pete) { Fabricate(:user) }

      before do
        session[:current_user_id] = pete.id
        request.env['HTTP_REFERER'] = "from_whence_I_came"
      end

      context "when review passes validations" do
        before do          
          post :create, review: Fabricate.attributes_for(:review), video_id: alpha.id
        end

        it "associates the correct video to @review" do
          expect(assigns(:review).user).to eq(pete)
        end

        it "associates the current user to @review" do
          expect(assigns(:review).video).to eq(alpha)
        end

        it "saves the review" do
          expect(Review.count).to eq(1)
        end

        it "sets flash[:success] message" do
          expect(flash[:success]).not_to be_blank
        end
        
        it "redirects back to video_path" do
          expect(response).to redirect_to "from_whence_I_came"
        end
      end

      context "when review fails validations" do
        before do
          session[:current_user_id] = Fabricate(:user).id
          post :create, review: { body: '' }, video_id: alpha.id
        end

        it "does not save the review" do
          expect(Review.count).to eq(0)
        end

        it "sets @video" do
          expect(assigns(:video)).to eq(alpha)
        end

        it "renders 'videos/show' template" do
          expect(response).to render_template "videos/show"
        end
      end
    end
  end
end