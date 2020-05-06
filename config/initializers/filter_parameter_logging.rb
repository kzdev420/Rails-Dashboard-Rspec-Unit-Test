# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :new_password, :vehicle_images, :parking_images, :number, :old_password]

# This filter is used for base64 images
Rails.application.config.filter_parameters << lambda do |k, v|
  if v.class == String && v.length > 1024
    v.replace('[FILTER]')
  end
end
