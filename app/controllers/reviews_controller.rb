class ReviewsController < ApplicationController
  def create
    @review = Review.new(review_params)
    @review.user = current_user
    @video = Video.find(params[:video_id])
    @review.video = @video

    if @review.save
      flash[:success] = "Thank you for your review!"
      redirect_to :back
    else
      render '/videos/show'
    end
  end

  private
    def review_params
      params.require(:review).permit(:body, :rating)
    end
end