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
      normalize_positions
      flash[:info] = "The video was removed from your queue."
    else
      flash[:danger] = "Access denied."
    end
    redirect_to :back
  end

  def update
    unless position_duplicates?
      begin
        update_queue_item_positions
        normalize_positions
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
      update_queue_positions_after_top(queue_item)
      queue_item.update(position: 1)
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

    def set_position
      current_user.queue_items.count + 1
    end

    def create_queue_item
      QueueItem.create(user: current_user, video: find_video, position: set_position)
    end

    def position_duplicates?
      positions = params[:queue_items].values.map { |qi| qi[:position] }
      positions.uniq.size != positions.size
    end

    def update_queue_item_positions
      QueueItem.find(params[:queue_items].keys).each do |qi| 
        qi.update!(position: params[:queue_items][qi.id.to_s][:position]) if qi.user == current_user
      end
    end

    def update_fails
      flash[:danger] = "Something went wrong. Please check your input and try again."
      redirect_to queue_path
    end

    def normalize_positions
      current_user.queue_items.each_with_index do |queue_item, i|
        queue_item.update(position: i+1)
      end
    end

    def update_queue_positions_after_top(queue_item)
      position_number = queue_item.position
      queue_item.user.queue_items.select { |qi| qi.position < position_number }.each do |qi| 
        qi.update(position: (qi.position + 1))
      end
    end
end