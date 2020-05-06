require 'sidekiq/web'

Sidekiq.configure_server do |config|
  config.redis = $redis_manager.ai_queue._client.options
  config.error_handlers << Proc.new { |exception| Raven.capture_exception(exception) }
  config.logger = nil
end

Sidekiq.configure_client do |config|
  config.redis = $redis_manager.ai_queue._client.options
end

require 'sidekiq/web'
Sidekiq::Web.set :session_secret, ENV['SECRET_KEY_BASE']
Sidekiq::Web.set :sessions,       Rails.application.config.session_options
Sidekiq::Web.class_eval do
  use Rack::Protection, except: :http_origin
end
# set the only locale to en_US (sidekiq web UI)
module Sidekiq
  module WebHelpers
    def locale
      'en'
    end
  end
end
