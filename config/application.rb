# frozen_string_literal: true

require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ParkingsApp
  class Application < Rails::Application
    config.load_defaults 5.2
    config.paths.add "lib", eager_load: true
    config.secret_key_base = ENV['SECRET_KEY_BASE']
    config.generators.system_tests = nil
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc
    config.i18n.load_path += Dir[Rails.root.join('config/locales', '**/*.yml')]
    config.to_prepare do
      # Or to configure mailer layout
      Devise::Mailer.layout "mailer" # email.haml or email.erb
    end
  end
end
