class UserDecorator < Draper::Decorator
  delegate_all

  def follow_or_unfollow_button(current_user)
    unless current_user == user
      if current_user.follows?(user)
        h.link_to "Unfollow", h.following_path(current_user.following_with(user)), method: :delete, class: 'btn btn-default pull-right'

      else
        h.link_to "Follow", h.followings_path(followee_id: user.id), method: :post, class: 'btn btn-default pull-right'
      end
    end
  end
end
