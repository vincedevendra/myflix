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
      queue_item.update_queue_positions_after_delete
      flash[:info] = "The video was removed from your queue."
    else
      flash[:danger] = "Access denied."
    end
    redirect_to :back
  end

  def update
    if position_input_valid?(all_positions_from_params)
      update_queue_item_positions
      flash[:info] = "Your queue has been updated."
      redirect_to :back
    else
      flash[:danger] = "Something went wrong. Please check your input and try again."
      redirect_to :back
    end
  end

  def top
    queue_item = QueueItem.find(params[:id])
    if queue_item.user == current_user
      queue_item.update_queue_positions_after_top
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

    def position_duplicates?(positions)
      positions.uniq.size != positions.size
    end

    def position_non_digits?(positions)
      !!positions.join.match(/\D/)
    end

    def position_too_high?(positions)
      !positions.select { |num_str| num_str.to_i > current_user.queue_items.size }.empty?
    end

    def position_input_valid?(positions)
      !position_duplicates?(positions) && !position_too_high?(positions) && !position_non_digits?(positions) 
    end

    def all_positions_from_params
      params[:queue_items].values.map { |qi| qi[:position] }
    end

    def queue_items_from_params
      QueueItem.find(params[:queue_items].keys)
    end

    def position_from_params(qi)
      params[:queue_items][qi.id.to_s][:position]
    end

    def update_queue_item_positions
      queue_items_from_params.each do |qi| 
        qi.update!(position: position_from_params(qi))
      end
    end
end