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

  describe "POST update" do
    
    context "when a user is signed in" do
      before { session[:current_user_id] = pete.id }
      
      context "when position changes pass validations" do

        context "when the user does not own one of the queue items." do
          let(:qi_1) { Fabricate(:queue_item, position: 1) }

          before { post :update, queue_items: { "#{qi_1.id}" => { position: 2, user_rating: 2 } } }                                      

          it "should not change that item" do
            expect(qi_1.reload.position).to eq(1)
          end

          it "should redirect to queue path" do
            expect(response).to redirect_to queue_path
          end
        end

        context "when positions are in the proper order" do
          let(:qi_1) { Fabricate(:queue_item, position: 1, user: pete) }
          let(:qi_2) { Fabricate(:queue_item, position: 2, user: pete) }

          before do 
            post :update, queue_items: { "#{qi_1.id}" => { position: 2, user_rating: 2 }, 
                                         "#{qi_2.id}" => { position: 1, user_rating: 2 } 
                                        }
          end

          it "updates position numbers for all affected queue items" do
            expect(qi_1.reload.position).to eq(2)
            expect(qi_2.reload.position).to eq(1)
          end

          it "redirects back" do
            expect(response).to redirect_to queue_path
          end

          it "sets info message" do
            expect(flash[:info]).to be_present
          end
        end

        context "when positions are not set in order" do
          let(:qi_1) { Fabricate(:queue_item, position: 1, user: pete) }
          let(:qi_2) { Fabricate(:queue_item, position: 2, user: pete) }
          let(:qi_3) { Fabricate(:queue_item, position: 3, user: pete) }

          before do   
            post :update, queue_items: { "#{qi_1.id}" => { position: 6, user_rating: 2 }, 
                                         "#{qi_2.id}" => { position: 3, user_rating: 2 },
                                         "#{qi_3.id}" => { position: 2, user_rating: 2 }
                                       }
          end

          it "normalizes position numbers" do                              
            expect(qi_1.reload.position).to eq(3)
            expect(qi_2.reload.position).to eq(2)
          end

          it "sets an info message" do
            expect(flash[:info]).to be_present
          end

          it "redirects back" do
            expect(response).to redirect_to queue_path
          end
        end

        context "when two positions are set to the same number" do
          let(:qi_1) { Fabricate(:queue_item, position: 1, user: pete) }
          let(:qi_2) { Fabricate(:queue_item, position: 2, user: pete) }

          before do 
            post :update, queue_items: { "#{qi_1.id}" => { position: 1, user_rating: 2 }, 
                                         "#{qi_2.id}" => { position: 1, user_rating: 2 } 
                                        }
          end

          it "doesn't change any position numbers" do
            expect(qi_1.position).to eq(1)
            expect(qi_2.position).to eq(2)
          end

          it "sets a danger message" do
            expect(flash[:danger]).to be_present
          end

          it "redirects back" do
            expect(response).to redirect_to queue_path
          end
        end

        context "when validations fail" do 
          context "when a position is set to a float" do
            let(:qi_1) { Fabricate(:queue_item, position: 1, user: pete) }
            let(:qi_2) { Fabricate(:queue_item, position: 2, user: pete) }

            before do
              post :update, queue_items: { "#{qi_1.id}" => { position: 1, user_rating: 2 }, 
                                           "#{qi_2.id}" => { position: 1.5, user_rating: 2 } 
                                          }
            end

            it "does not update any queue items" do
              expect(qi_1.reload.position).to eq(1)
              expect(qi_2.reload.position).to eq(2)
            end

            it "sets a danger message" do
              expect(flash[:danger]).to be_present
            end

            it "redirects back" do
              expect(response).to redirect_to queue_path
            end
          end

          context "when a position contains a non-digit character" do
            let(:qi_1) { Fabricate(:queue_item, position: 1, user: pete) }
            let(:qi_2) { Fabricate(:queue_item, position: 2, user: pete) }

            before do
              post :update, queue_items: { "#{qi_1.id}" => { position: "1123a", user_rating: 2 }, 
                                           "#{qi_2.id}" => { position: 1.5, user_rating: 2 } 
                                          }
            end

            it "does not update any queue items" do
              expect(qi_1.reload.position).to eq(1)
              expect(qi_2.reload.position).to eq(2)
            end

            it "sets a danger message" do
              expect(flash[:danger]).to be_present
            end

            it "redirects back" do
              expect(response).to redirect_to queue_path
            end
          end

          context "when a position is set to a negative number" do
            let(:qi_1) { Fabricate(:queue_item, position: 1, user: pete) }
            let(:qi_2) { Fabricate(:queue_item, position: 2, user: pete) }

            before do   
              post :update, queue_items: { "#{qi_1.id}" => { position: 1, user_rating: 2 }, 
                                           "#{qi_2.id}" => { position: -1, user_rating: 2 } 
                                          }
            end

            it "does not update any queue items" do                              
              expect(qi_1.reload.position).to eq(1)
              expect(qi_2.reload.position).to eq(2)
            end

            it "sets a danger message" do
              expect(flash[:danger]).to be_present
            end

            it "redirects back" do
              expect(response).to redirect_to queue_path
            end
          end
        end
      end
    
      context "when user changes video rating and validations pass" do
          let(:video1) { Fabricate(:video) }
          let(:video2) { Fabricate(:video) }
          let!(:qi_1) { Fabricate(:queue_item, position: 1, user: pete, video: video1) }
          let!(:qi_2) { Fabricate(:queue_item, position: 2, user: pete) }
          let!(:review1) { Fabricate(:review, user: pete, rating: 1, video: video1) }

        it "updates the reviews if it already exists" do
          post :update, queue_items: { "#{qi_1.id}" => { position: 1, user_rating: 4 } }
          expect(qi_1.reload.user_rating).to eq(4)
        end

        it "creates a review with only the rating if it does not exist" do
          post :update, queue_items: { "#{qi_2.id}" => { position: 1, user_rating: 4 } }
          expect(qi_2.reload.user_rating).to eq(4)
        end
      end

      context "when no rating exists and none is selected" do
        let(:qi_1) { Fabricate(:queue_item, position: 1, user: pete) }
        let(:qi_2) { Fabricate(:queue_item, position: 2, user: pete) }

        before do
          post :update, queue_items: { "#{qi_1.id}" => { position: 2, user_rating: "" },
                                       "#{qi_2.id}" => { position: 1, user_rating: "" }
                                      }
        end

        it "does not create a review" do
          expect(qi_1.reload.user_review).to be_falsy
        end

        it "still updates the position number" do
          expect(qi_1.reload.position).to eq(2)
        end
      end

      context "when user changes video rating and validations fail" do
        let(:qi_1) { Fabricate(:queue_item, position: 1, user: pete) }

        before { post :update, queue_items: { "#{qi_1.id}" => { position: 3, user_rating: 6 } } }

        it "doesn't update anything" do
          expect(qi_1.reload.user_rating).to be_falsy
          expect(qi_1.reload.position).to eq(1)
        end

        it "redirect_to queue_path" do
          expect(response).to redirect_to queue_path
        end
      end
    end

    context "when no user is signed in" do
      let(:qi_1) { Fabricate(:queue_item, position: 1, user: pete) }

      it "redirect_to welcome_path" do
        post :update, queue_items: { "#{qi_1.id}" => { position: 2, user_rating: 2 } }
        expect(response).to redirect_to welcome_path
      end
    end
  end

  describe "POST top" do
    let!(:qi_1) { Fabricate(:queue_item, position: 1, user: pete) }
    let!(:qi_2) { Fabricate(:queue_item, position: 2, user: pete) }
    let!(:qi_3) { Fabricate(:queue_item, position: 3, user: pete) }

    context "when a user is signed in" do 
      before do
        session[:current_user_id] = pete.id
        post :top, id: qi_2.id
      end

      it "sets the position of the item to 1" do
        expect(qi_2.reload.position).to eq(1)
      end

      it "adds one to the relevant item positions" do
        expect(qi_1.reload.position).to eq(2)
      end

      it "leaves alone the relevant item positions" do
        expect(qi_3.reload.position).to eq(3)
      end

      it "sets an info message" do
        expect(flash[:info]).to be_present
      end

      it "redirects to the queue_path" do
        expect(response).to redirect_to queue_path
      end
    end

    context "when no user is signed in" do
      it "redirects to welcome_path" do
        post :top, id: qi_2.id
        expect(response).to redirect_to welcome_path
      end
    end
  end
end
      
