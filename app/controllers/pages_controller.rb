class PagesController < ApplicationController
  skip_before_action :require_user, only: [:welcome, :invalid_token]
  before_action :redirect_when_logged_in, only: :welcome
end
