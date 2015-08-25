require 'spec_helper'

describe Admin::VideosController do
  describe "GET new" do
    it "sets @video to a new Video" do
      set_admin
      get :new
      expect(assigns(:video)).to be_a_new(Video)
    end

    it_behaves_like "no admin redirect" do
      let(:action) { get :new }
    end

    it_behaves_like "no_current_user_redirect" do
      let(:action) { get :new }
    end
  end
end
