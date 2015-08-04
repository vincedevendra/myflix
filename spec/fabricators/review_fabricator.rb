Fabricator(:review) do
  body { Faker::Lorem.paragraph }
  rating { Faker::Number.between(1, 5)}
  video { Fabricate(:video) }
  user { Fabricate(:user) }
end