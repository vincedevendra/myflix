require 'spec_helper'

describe VideosController do
  describe 'GET show' do
    let(:video) { Fabricate(:video) }

    context "when a user is signed in" do
      before { session[:current_user_id] = Fabricate(:user).id }
      
      it "sets @video" do
        get :show, id: video.id
        expect(assigns(:video)).to eq(video)
      end

      it "sets @review" do
        get :show, id: video.id
        expect(assigns(:review)).to be_a_new(Review)
      end  
    end

    context "when a user is not signed in" do
      it "redirects to welcome_path" do
        get :show, id: video.id
        expect(response).to redirect_to(welcome_path)
      end
    end
  end

  describe 'GET search' do
    let(:video) { Fabricate(:video) }
    
    it "sets @videos for signed in user" do
      session[:current_user_id] = Fabricate(:user).id
      get :search, query: video.title
      expect(assigns(:videos)).to eq([video])
    end
       
    it "redirects to welcome page if no signed in user" do
      get :search
      expect(response).to redirect_to(welcome_path)
    end
  end
end