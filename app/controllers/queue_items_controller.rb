class QueueItemsController < ApplicationController

  def index
    @queue_items = current_user.queue_items
  end

  def create
    create_queue_item unless current_user.has_video_in_queue?(find_video)
    flash[:success] = "This video was added to your queue."
    redirect_to :back
  end

  def destroy
    queue_item = QueueItem.find(params[:id])
    if queue_item.user == current_user
      queue_item.destroy
      current_user.normalize_queue_item_positions
      flash[:info] = "The video was removed from your queue."
    else
      flash[:danger] = "Access denied."
    end
    redirect_to :back
  end

  def update
    unless position_duplicates?
      begin
        update_queue_items
        current_user.normalize_queue_item_positions
      rescue ActiveRecord::RecordInvalid
        update_fails and return
      end

      flash[:info] = "Your queue has been updated."
      redirect_to queue_path
    else
      update_fails
    end
  end

  def top
    queue_item = QueueItem.find(params[:id])
    if queue_item.user == current_user
      queue_item.move_to_top_and_fix_positions
      flash[:info] = "The video was moved to the top of your queue."
    else
      flash[:danger] = "Access denied."
    end

    redirect_to queue_path
  end

  private
    def find_video
      Video.find(params[:video_id])
    end

    def create_queue_item
      QueueItem.create(user: current_user, video: find_video, position: current_user.position_of_new_queue_item)
    end

    def position_duplicates?
      positions = params[:queue_items].values.map { |qi| qi[:position] }
      positions.uniq.size != positions.size
    end

    def update_queue_item_positions
      params[:queue_items].each do | queue_item_id, data_hash |
        queue_item = QueueItem.find(queue_item_id)
        queue_item.update!(position: data_hash[:position]) if queue_item.user == current_user
      end
    end

    def update_user_ratings
      params[:queue_items].each do | queue_item_id, data_hash |
        queue_item = QueueItem.find(queue_item_id)
        review = queue_item.user_review
        new_rating = data_hash[:user_rating]

        if review
          review.update!(skip_body: true, rating: new_rating)
        else
          Review.create!(skip_body: true, user: current_user, video: queue_item.video, rating: new_rating)
        end
      end
    end

    def update_queue_items
      ActiveRecord::Base.transaction do
        update_queue_item_positions
        update_user_ratings
      end
    end

    def update_fails
      flash[:danger] = "Something went wrong. Please check your input and try again."
      redirect_to queue_path
    end
end