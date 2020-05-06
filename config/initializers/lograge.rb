Rails.application.configure do
  exceptions = %w[controller action format id]
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    unless event.name.include?('cable')
      headers = event.payload[:headers]
      tracker_id = headers['psad-tracker-id'] || ''
      params = event.payload[:params].except(*exceptions)
    else
      tracker_id = ''
      params = event.payload[:data]
    end
    body_response = event.payload[:body_response]
    {
      tracker_id: tracker_id,
      request_date: Time.zone.now.strftime('%m-%d-%Y %H:%M:%S'),
      params: params,
      response: body_response
    }
  end
end
