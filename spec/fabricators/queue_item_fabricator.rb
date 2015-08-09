Fabricator(:queue_item) do
  position { rand(1..10) }
  user
  video
end