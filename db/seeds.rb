# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



Fabricate.times(4, :category)

20.times do
  Fabricate(:video, category: Category.all.sample)
end

Fabricate.times(10, :user)
Fabricate(:user, full_name: 'Vince D', email: 'vj@d.com')

Video.all.each do |video|
  4.times do
    Fabricate(:review, video: video, user: User.all.sample)
  end
end

q = QueueItem.create(user: User.find_by(full_name: 'Vince D'))
q.videos = Video.all
