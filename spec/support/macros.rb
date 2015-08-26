require 'spec_helper'

def set_current_user(user=nil)
  user = user || Fabricate(:user)
  session[:current_user_id] = user.id
end

def current_user
  User.find(session[:current_user_id]) if session[:current_user_id]
end

def clear_current_user
  session[:current_user_id] = nil
end

def sign_in_user(user=nil)
  user ||= Fabricate(:user)
  visit '/sign_in'
  fill_in "Email Address", with: user.email
  fill_in "Password", with: 'password'
  click_button 'Sign In'
end

def click_video_link(video)
  find("a[href='/videos/#{video.id}']").click
end

def set_admin(user=nil)
  user ||= Fabricate(:user, admin: true)
  session[:current_user_id] = user.id
end

def sign_out
  click_link "Sign Out"
end

def sign_in_admin(admin=nil)
  admin ||= Fabricate(:admin)
  sign_in_user(admin)
end
