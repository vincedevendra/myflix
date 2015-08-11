def set_current_user
  user = Fabricate(:user)
  session[:current_user_id] = user.id
end

def current_user
  User.find(session[:current_user_id]) if session[:current_user_id]
end

def clear_current_user
  session[:current_user_id] = nil
end