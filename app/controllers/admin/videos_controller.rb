class Admin::VideosController < AdminController
  def new
    @video = Video.new
  end

  def create
    @video = Video.new(params.require(:video).permit(:title, :description, :small_cover, :category_id, :large_cover, :video_url))

    if @video.save
      flash[:success] = "The video #{@video.title} has been created."
      redirect_to new_admin_video_path
    else
      flash[:danger] = "The video was not saved.  Please fix the following errors:"
      render 'new'
    end
  end
end
