class AdminController < ApplicationController
  before_action :ensure_admin

  private
    def ensure_admin
      unless current_user.admin?
        flash[:danger] = "You do not have access to this area of the site."
        redirect_to root_path
      end
    end
end
