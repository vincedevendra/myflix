class QueueItemsController < ApplicationController

  def index
    @queue_items = current_user.queue_items
  end

  def create
    new_queue_item = build_queue_item

    if new_queue_item.save
      flash[:success] = "This video was added to your queue."
    else
      flash[:danger] = "This video is already on your queue."
    end

    redirect_to :back
  end

  def destroy
    queue_item = QueueItem.find(params[:id])
    if queue_item.user == current_user
      queue_item.destroy
      queue_item.update_queue_position_numbers
      flash[:info] = "The video was removed from your queue."
    else
      flash[:danger] = "Access denied."
    end
    redirect_to :back
  end

#Not worried about this yet:
  # def update
  #   binding.pry
  # end

  private
    def find_video
      Video.find(params[:video_id])
    end

    def set_position
      current_user.queue_items.count + 1
    end

    def build_queue_item
      QueueItem.new(user: current_user, video: find_video, position: set_position)
    end
end