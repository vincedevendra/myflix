module ApplicationHelper
  def ratings_choices
    (1..5).reverse_each.map { |n| [pluralize(n, "Star"), n]}
  end

  def gravatar_for(user)
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email.downcase)}?s=40"
  end

  def follow_or_unfollow_button(current_user, user)
    unless current_user == user
      if current_user.follows?(user)
        link_to "Unfollow", following_path(current_user.following_with(user)), method: :delete, class: 'btn btn-default pull-right'

      else
        link_to "Follow", followings_path(followee_id: user.id), method: :post, class: 'btn btn-default pull-right'
      end
    end
  end

  def add_or_remove_from_queue_button(user, video)
    unless user.has_video_in_queue?(video)
      link_to '+ My Queue', video_queue_items_path(video), method: 'post', class: 'btn btn-default'
    else
      link_to 'X Remove From Queue', queue_item_path(user.video_queue_item(video)), method: :delete, class: 'btn btn-default', id: 'remove-button'
    end
  end

  def display_last_4(card)
    "************#{card.last4}"
  end

  def display_expiration_date(card)
    "#{card.exp_month}/#{card.exp_year}"
  end

  def email_value
    @invite_email ? @invite_email : @user.email
  end

  def name_value
    @invite_name ? @invite_name : @user.full_name
  end

  def account_details_link
    link_to "update your payment method", account_details_path
  end
end
