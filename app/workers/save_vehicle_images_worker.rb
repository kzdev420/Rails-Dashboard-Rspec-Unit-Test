class SaveVehicleImagesWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers
  sidekiq_options queue: :images

  def perform(record_id, images, unrecognized_lpn, parking_slot_id, uuid)
    record = Vehicle.find(record_id)
    PaperTrail.request.disable_model('Vehicle')
    images_url_alert = []
    images.each do |image|
      return if image.empty?
      unless stored_image = record.images.attach({ data: image })
        errors.merge!(image.errors)
        throw(:abort)
      end
      images_url_alert.push(url_for(stored_image.first))
    end
    if unrecognized_lpn
      logger = Logger.new("#{Rails.root}/log/ai/sentry_sent.log")
      logger.info("UUID alert sent: #{uuid}") # Check if alert was sent for certain session
      Raven.tags_context(ai_event: 'car_parked')
      Raven.extra_context(picture_url: images_url_alert, parking_slot_id: parking_slot_id, uuid: uuid)
      Raven.capture_exception(Exception.new("LPN not recognized at parking slot #{parking_slot_id} (UUID #{uuid})"))
    end
  end

end