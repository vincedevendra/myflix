class UiController < ApplicationController
  skip_before_action :require_user

  before_filter do
    redirect_to :root if Rails.env.production?
  end

  layout "application"

  def index
  end
end
