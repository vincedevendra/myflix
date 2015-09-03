class VideoDecorator < Draper::Decorator
  delegate_all

  def average_rating
    if video.reviews.any?
      "Rating: #{video.average_rating} / 5.0"
    end
  end
end
