require 'spec_helper'

describe VideosController do
  describe 'GET show' do
    let(:video) { Fabricate(:video) }
    before { set_current_user }

    it "sets @video" do
      get :show, id: video.id
      expect(assigns(:video)).to eq(video)
    end

    it "sets @review" do
      get :show, id: video.id
      expect(assigns(:review)).to be_a_new(Review)
    end

    it_behaves_like "no_current_user_redirect" do
      let(:action) { get :show, id: video.id }
    end

    it_behaves_like "no valid subscription redirect" do
      let(:action) { get :show, id: video.id }
    end
  end

  describe 'GET search' do
    let(:video) { Fabricate(:video) }

    it "sets @videos for signed in user" do
      set_current_user
      get :search, query: video.title
      expect(assigns(:videos)).to eq([video])
    end

    it_behaves_like "no_current_user_redirect" do
      let(:action) { get :search }
    end

    it_behaves_like "no valid subscription redirect" do
      let(:action) { get :search }
    end
  end
end
