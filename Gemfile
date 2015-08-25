source 'https://rubygems.org'
ruby '2.1.7'

gem 'bootstrap-sass'
gem 'coffee-rails'
gem 'rails', '4.1.1'
gem 'haml-rails'
gem 'sass-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'pg'
gem 'bootstrap_form'
gem 'bcrypt'
gem 'fabrication'
gem 'faker'
gem 'figaro'
gem 'sidekiq'
gem 'unicorn'
gem 'carrierwave'
gem 'carrierwave-aws'
gem 'mini_magick'

group :development do
  gem 'thin'
  gem "better_errors"
  gem 'letter_opener'
  gem "binding_of_caller"
end

group :development, :test do
  gem 'pry'
  gem 'pry-nav'
  gem 'rspec-rails', '2.99'
  gem 'launchy'
end

group :test do
  gem 'database_cleaner', '1.2.0'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'capybara-email'
end

group :production, :staging do
  gem 'rails_12factor'
  gem "sentry-raven", :git => "https://github.com/getsentry/raven-ruby.git"
end
