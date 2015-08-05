Fabricator(:review) do
  body { Faker::Lorem.paragraph }
  rating { Faker::Number.between(1, 5) }
  user { Fabricate(:user) }
  video { Fabricate(:video) }
end
