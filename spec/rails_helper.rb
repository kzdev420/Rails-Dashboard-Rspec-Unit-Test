# frozen_string_literal: true
# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f } # helpers
Dir[Rails.root.join('spec/factories/**/*.rb')].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

require 'sidekiq/testing'
# Sidekiq::Testing.fake! (default) jobs are stored in WorkerClass#jobs array instead of Redis instance
Sidekiq::Testing.inline! # jobs are executed immediately instead of queueing

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include RequestHelper, type: :request
  config.include AuthHelper, type: :request
  config.include UploadsHelper
  config.include AiEventsHelper
  config.include RolesHelper
  config.include ActiveSupport::Testing::TimeHelpers

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.filter_run(show_in_doc: true) if ENV['APIPIE_RECORD']
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    RolesSeedCommand.execute
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after(:each) do |example|
    DatabaseCleaner.clean unless @disable_database_cleaner
    $redis_manager.flushall
  end
end
