module ApplicationHelper
  def ratings_choices
    (1..5).reverse_each.map { |n| [pluralize(n, "Star"), n]}
  end

  def gravatar_for(user)
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email.downcase)}?s=40"
  end
end
