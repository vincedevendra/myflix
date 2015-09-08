class VideosController < ApplicationController
  skip_before_action :require_user, only: :index
  skip_before_action :require_valid_subscription, only: :index

  def index
    redirect_to welcome_path unless logged_in?
    @categories = Category.all
  end

  def show
    @video = Video.find(params[:id]).decorate
    @review = Review.new
  end

  def search
    @videos = Video.search_by_title(params[:query])
    render 'search_results'
  end
end
