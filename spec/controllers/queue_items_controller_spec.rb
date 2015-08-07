require 'spec_helper'

describe QueueItemsController do
  let(:pete) { Fabricate(:user) }

  describe "GET index" do

    context "when a user is signed in" do
      let(:q1) { Fabricate(:queue_item, user: pete, position: 1) }
      let(:q2) { Fabricate(:queue_item, user: pete, position: 2) }
            
      before { session[:current_user_id] = pete.id }
      
      it "sets @queue_items to those that belong to current user" do
        get :index
        expect(assigns(:queue_items)).to match_array([q1, q2])
      end
    end
      
    context "When no user is signed in" do
      it "redirects to welcome_path" do
        get :index
        expect(response).to redirect_to welcome_path
      end
    end
  end

  describe "POST create" do
    let(:video) { Fabricate(:video) }

    context "when a user is signed in" do
      before do
        session[:current_user_id] = pete.id
        request.env['HTTP_REFERER'] = "from_whence_I_came"
      end
      
      context "when the video is not yet in the user's queue" do
        before do
          session[:current_user_id] = pete.id
          request.env['HTTP_REFERER'] = "from_whence_I_came"
        end
          
        it "creates an instance of QueueItem" do
          post :create, video_id: video.id
          expect(QueueItem.count).to eq(1)
        end

        it "associates new queue item with current user" do
          post :create, video_id: video.id
          expect(QueueItem.first.user).to eq(pete)
        end

        it "associates new queue item with video" do
          post :create, video_id: video.id
          expect(QueueItem.first.video).to eq(video)
        end

        it "assigns the new QueueItem one greater than the highest position of existing queue items" do
          Fabricate(:queue_item, position: 1, user: pete)
          post :create, video_id: video.id
          expect(QueueItem.last.position).to eq(2)
        end

        it "sets flash[:success]" do
          post :create, video_id: video.id
          expect(flash[:success]).to be_present
        end

        it "redirects back to the previous page" do
          post :create, video_id: video.id
          expect(response).to redirect_to "from_whence_I_came"
        end
      end

      context "when the video is already in the user's queue" do
        before do 
          Fabricate(:queue_item, position: 1, user: pete, video: video)
          post :create, video_id: video.id
        end

        it "doesn't save the queue item" do
          expect(QueueItem.count).to eq(1)
        end

        it "sets flash[:danger] message" do
          expect(flash[:danger]).to be_present
        end

        it "redirects back to the previous page" do
          expect(response).to redirect_to "from_whence_I_came"
        end
      end
    end

    context "when no user is signed in" do
      it "redirects_to welcome_path" do
        post :create, video_id: video.id
        expect(response).to redirect_to(welcome_path)
      end
    end
  end

  describe "DELETE destroy" do
    let(:pete) { Fabricate(:user) }
    let(:james) { Fabricate(:user) }
    let (:video1) { Fabricate(:video) }
    let (:video2) { Fabricate(:video) }
    let!(:q1) { Fabricate(:queue_item, position: 1, user: pete, video: video1) }
    let!(:q2) { Fabricate(:queue_item, position: 1, user: james, video: video2) }
    let!(:q3) { Fabricate(:queue_item, position: 2, user: james, video: Fabricate(:video)) }

    context "when a user is signed in" do
      before do
        session[:current_user_id] = james.id
        request.env['HTTP_REFERER'] = "from_whence_I_came"
        delete :destroy, id: q2.id
      end

      context "when current user owns the queue item" do
        it "deletes a queue item" do
          expect(QueueItem.count).to eq(2)
        end

        it "flashes info message" do
          expect(flash[:info]).to be_present
        end

        it "reduces the position of all items deleted item was in front of by one" do
          expect(q3.reload.position).to eq(1)
        end

        it "redirects :back" do
          expect(response).to redirect_to "from_whence_I_came"
        end
      end

      context "when current user does not own queue item" do
        before { delete :destroy, id: q1.id }

        it "deletes a queue item only if the current user owns it" do
          expect(:q1).to be_truthy
        end

        it "flashes a danger message if no video is deleted" do
          expect(flash[:danger]).to be_present
        end
      end
    end

    context "when no user is signed in" do
      before { delete :destroy, id: q2.id }

      it "doesn't delete any queue items" do
        expect(QueueItem.count).to eq(3)
      end

      it "redirect_to welcome_path" do
        expect(response).to redirect_to welcome_path
      end
    end
  end
end
# Not worried about this yet:
#   describe "PATCH update" do
#     context "when a user is signed in" do
#       let(:pete) { Fabricate(:user) }
#       context "when user changes position numbers" do
#         context "when the changes pass validations" do
#           it "finds queue_items with changed position numbers"
#           it "updates position numbers for all affected queue items"
#           it "redirects back"
#           it "sets info message"
#         context "when the changes fail validations" do
#           it "does not update any queue items"
#           it "renders 'queue_items/index' template"
#         end
#       end
#       context "when user changes video rating" do
#         let(:video1) { Fabricate(:video) }
#         let(:video2) { Fabricate(:video) }
#         let(:review1) { Fabricate(:review, rating: 1, video: video1) }
#         let(:review2) { Fabricate(:review, rating: 2, video: video2) }
#         let(:q1) { QueueItem.create(position: 1, user: pete, video: video1) }
#         let(:q2) { QueueItem.create(position: 2, user: pete, video: video2) }

#         it "finds all the reviews that are being changed"

#         it "updates the reviews that are being changed" do
#           # patch :update, id: 
#         end
#         it "sets info message"
#         it "redirects back"
#       end
#       context "when nothing is changed" do
#         it "sets warning message"
#         it "redirects back"
#       end
#     end
#     context "when no user is signed in" do
#       it "redirect_to welcome_path"
#     end
#   end
# end