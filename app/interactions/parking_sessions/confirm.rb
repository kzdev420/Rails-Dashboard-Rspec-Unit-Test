module ParkingSessions
  class Confirm < ::ApplicationInteraction
    include Logging

    integer :check_out, default: 60.minutes.from_now.to_i
    object :object, class: ParkingSession
    object :kiosk, class: Kiosk, default: nil
    string :gateway, default: nil
    hash :gateway_params, strip: false, default: {}

    validate do
      if check_out < object.check_in.to_i
        errors.add(:check_out, :invalid)
        throw(:abort)
      end
    end

    def execute
      begin
        object.check_out = Time.at(check_out)
        transactional_compose!(ParkingSessions::Pay, object: object, gateway: gateway, params: gateway_params)
      rescue ::Payments::StandardError => e
        raise ::Payments::StandardError, e.message
      end

      ParkingSession.transaction do
        if object.finished?
          transactional_update!(
            object,
            check_out: Time.at(check_out)
          )
        elsif object.confirmed?
          transactional_compose!(::ParkingSessions::Extend, object: session, check_out: check_out)
        else
          transactional_update!(
            object,
            check_out: Time.at(check_out),
            status: :confirmed,
            fee_applied: object.parking_lot.rate,
            kiosk_id: kiosk&.id
          )
        end
      end
      resolve_alerts
      broadcast_to_parking_spaces
      Ai::Parking::OvertimeTickerWorker.extend_or_create(object)
    end

    private

    def session
      object
    end

    def resolve_alerts
      object.alerts.each do |alert|
        transactional_update!(alert, status: :resolved)
      end
    end

    def broadcast_to_parking_spaces
      ActionCable.server.broadcast("parking_spaces_channel_#{object.parking_lot.id}",::Api::Dashboard::Parking::SlotSerializer.new(object.parking_slot))
    end

  end
end
