module ApplicationHelper
  def ratings_choices
    (1..5).reverse_each.map { |n| [pluralize(n, "Star"), n]}
  end
end
