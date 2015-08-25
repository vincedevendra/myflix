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

  describe "POST create" do
    let(:action) { post :create, Fabricate.attributes_for(:video) }

    it_behaves_like "no_current_user_redirect"
    it_behaves_like "no admin redirect"
    
    context "when validations pass" do
      before do
        set_admin
        post :create, video: Fabricate.attributes_for(:video)
      end

      it "creates a new video" do
        expect(Video.count).to eq(1)
      end

      it "sets a flash message" do
        expect(flash[:success]).to be_present
      end

      it "redirects to the new_admin_video path" do
        expect(response).to redirect_to new_admin_video_path
      end
    end

    context "when validations fail" do
      before do
        set_admin
        post :create, video: Fabricate.attributes_for(:video, title: nil)
      end

      it "does not create a new video" do
        expect(Video.count).to eq(0)
      end

      it "sets a flash message" do
        expect(flash[:danger]).to be_present
      end

      it "renders the new template" do
        expect(response).to render_template 'new'
      end
    end
  end
end
