require 'spec_helper'

describe QueuesController do
  describe "GET show" do

    context "when a user is signed in" do
      let(:pete) { Fabricate(:user) }
            
      before { session[:current_user_id] = pete.id }
      
      it "creates a new queue for the user if (s)he doesn't have one" do
        get :show, user_id: pete.id
        expect(pete.queue_item).to be_truthy
      end      
        
      it "sets @videos from the user's queue" do
        let(:q) { QueueItem.create(user: pete) }
        let(:alpha) { Fabricate(:video, queue_item: q) }
        let(:beta) { Fabricate(:video, queue_item: q) }
        get :show, user_id: pete.id
        expect(assigns(:videos)).to match_array(q.videos)
      end
    end
      
    context "When no user is signed in" do
      it "redirects to welcome_path" do
        get :show, user_id: '1'
        expect(response).to redirect_to welcome_path
      end
    end
  end
end