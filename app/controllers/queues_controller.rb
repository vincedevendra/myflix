class QueuesController < ApplicationController
  def show
    current_user.create_queue_item unless current_user.queue_item
    @videos = current_user.queue_item.videos
  end
end