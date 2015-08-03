# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


  category1 = Category.create(title: "Comedies")
  category2 = Category.create(title: "Dramas")
  category3 = Category.create(title: "Reality")

  4.times do 
    Video.create!(title: 'Family Guy', 
                  description: 'A show', 
                  small_cover_url: '/tmp/family_guy.jpg', 
                  large_cover_url: '/tmp/monk_large.jpg',
                  category: category1)
  end
  
  3.times do 
    Video.create!(title: 'Futurama', 
                  description: 'A show', 
                  small_cover_url: '/tmp/futurama.jpg', 
                  large_cover_url: '/tmp/monk_large.jpg',
                  category: category1)
  end

  2.times do 
    Video.create!(title: 'Family Guy', 
                  description: 'A show', 
                  small_cover_url: '/tmp/family_guy.jpg', 
                  large_cover_url: '/tmp/monk_large.jpg',
                  category: category2)
  end
  
  3.times do 
    Video.create!(title: 'Futurama', 
                  description: 'A show', 
                  small_cover_url: '/tmp/futurama.jpg', 
                  large_cover_url: '/tmp/monk_large.jpg',
                  category: category2)
  end
