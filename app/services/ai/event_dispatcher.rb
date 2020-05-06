module Ai
  class EventDispatcher
    attr_reader :payload, :event_type, :parking_lot

    def initialize(data = {})
      @payload = data.with_indifferent_access
      @parking_lot = ParkingLot.find_by(id: payload[:parking_lot_id]) || ParkingLot.first
      @event_type = payload[:event_type].to_s
      payload.delete(:event_type) && payload.delete(:parking_lot_id)
    end

    def self.dispatch(payload = {})
      new(payload).dispatch
    end

    def dispatch
      params = payload.merge(parking_lot: parking_lot).merge!(payload.delete(:parking_session) || {})
      handler = "ParkingSessions::#{event_type.camelize}".safe_constantize

      unless handler.respond_to?(:run)
        return unknown_event!
      end

      result = handler.run(params)

      if result.valid?
        success!
      else
        fail!(result.errors.full_messages.join(', '))
      end
    rescue => exc
      fail!(exc.message)
      Raven.capture_exception(exc)
    end

    private

    LoggingError = Class.new(StandardError)

    def unknown_event!
      fail!("Payload has invalid event type '#{event_type}'")
    end

    def success!
      true
    end

    def fail!(error_message)
      false
    end
  end
end
