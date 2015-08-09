Fabricator(:video) do
  title { Faker::Lorem.words(3).join(" ")}
  description { Faker::Lorem.paragraph }
  category 
  small_cover_url ['/tmp/family_guy.jpg', '/tmp/futurama.jpg', '/tmp/family_guy.jpg'].sample
  large_cover_url '/tmp/monk_large.jpg' 
end