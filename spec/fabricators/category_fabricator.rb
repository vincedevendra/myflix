Fabricator(:category) do
  title { Faker::Lorem.words(3).join(" ")}  
end