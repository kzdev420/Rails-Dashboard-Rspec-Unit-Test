module ParkingSessions::Logging
  extend ActiveSupport::Concern

  included do
    set_callback :execute, :after, :write_log, if: :valid?
  end

  private

  def write_log
    name = self.class.name.demodulize.underscore
    slot_name = @slot.present? ? @slot.name : nil
    parking_lot_name = @parking_lot.present? ? @parking_lot.name : nil
    session.reload.logs.first.update(comment: I18n.t("parking/log.text.#{name}", lot_name: parking_lot_name, slot_name: slot_name, device: device_confirmed(name) ))
  rescue => ex
    Rails.logger.error("Session event logging failed due to: #{ex.message}")
    Rails.logger.info { inspect }
    Raven.capture_exception(ex)
  end

  def device_confirmed(name)
    if name == 'confirm'
      inputs[:kiosk].nil? ? 'mobile app' : 'kiosk app'
    end
  end
end
