Rails.application.config.middleware.insert_before 0, Rack::Cors do
  exposed = ['x-total', 'x-per-page', 'x-page', 'psad-tracker-id'] # api pagination

  allow do
    origins '*'
    resource '/api/*', headers: :any, methods: [:get, :post, :options, :put, :delete], expose: exposed
  end
end
