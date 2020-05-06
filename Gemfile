# frozen_string_literal: true
ruby '~> 2.5.1'
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'rails', '~> 5.2.1'
gem 'pg'
gem 'puma'
gem 'sass-rails'
gem 'coffee-rails'
gem 'slim-rails'
gem 'webpacker'
gem 'uglifier'
gem 'jbuilder'
gem 'administrate'
gem 'json2table'
gem 'bootsnap', require: false

gem 'bootstrap'
gem 'font-awesome-rails'
gem 'jquery-rails'
gem 'devise'
gem 'active_interaction', '~> 3.6' # form-object
gem 'phony_rails' # phone validation
gem 'active_model_serializers'
gem 'responders'
gem 'apipie-rails' # api documentation
gem 'rack-cors', require: 'rack/cors'
gem 'whenever', require: false
gem 'tzinfo-data'
gem 'sentry-raven'
gem 'action_policy', github: 'palkan/action_policy'
gem 'effective_addresses'
gem 'credit_card_validations'
gem 'paper_trail'
gem 'spreadsheet_architect'
gem 'http'

# images
gem 'active_storage_base64'
gem 'active_storage_validations'
gem 'mini_magick'

gem 'kaminari'
gem 'api-pagination'

gem 'redis-rails'
gem 'faker'

# background processing, requires redis
gem 'sidekiq'

# Log format
gem 'lograge'

# Push notifications
gem 'fcm'

group *%i[development test] do
  gem 'awesome_print'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.8'
  gem 'rubocop', require: false
end

group :test do
  gem 'factory_bot'
  gem 'database_cleaner', '>=1.6.0'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background.
  gem 'listen'
  gem 'spring'
  gem 'bullet'
  gem 'spring-watcher-listen'
  # Project Documentation
  gem 'yard'
  gem 'redcarpet'
end

group :production do
  gem 'unicorn'
end
