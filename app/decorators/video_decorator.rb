class VideoDecorator < Draper::Decorator
  delegate_all

  def average_rating
    if video.reviews.any?
      "Rating: #{video.average_rating} / 5.0"
    end
  end

  def add_or_remove_from_queue_button(user)
    unless user.has_video_in_queue?(video)
      h.link_to '+ My Queue', h.video_queue_items_path(video), method: 'post', class: 'btn btn-default'
    else
      h.link_to 'X Remove From Queue', h.queue_item_path(user.video_queue_item(video)), method: :delete, class: 'btn btn-default', id: 'remove-button'
    end
  end
end
