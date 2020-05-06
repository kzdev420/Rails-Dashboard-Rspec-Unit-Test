if Rails.env.production?
  Raven.configure do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.tags = { source: 'rails' }
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    config.async = lambda do |event|
      Thread.new { Raven.send_event(event) }
    end

    # Exceptions cause when file was remove by a production deployment
    config.excluded_exceptions += [
      'IOError',
      'Errno::ENOENT'
    ]
  end
end
