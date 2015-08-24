Fabricator(:invite) do
  email { Faker::Internet.email }
  name { Faker::Name.name }
  message { Faker::Lorem.paragraphs(2).join }
  token { SecureRandom.urlsafe_base64 }
  user_id { Faker::Number.between(1, 10) }
end