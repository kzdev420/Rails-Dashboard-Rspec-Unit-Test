module ParkingSessions
  class Pay < ApplicationInteraction
    object :object, class: ParkingSession
    string :gateway, default: nil
    hash :params, strip: false, default: {}

    def execute
      payment_info = object.payment_info

      if payment_info.paid?
        errors.add(:base, 'already paid') and return
      end

      if gateway.present?
        begin
          payment = payment_gateway.new(payment_info, object, params).pay!
          payment.update(payment_gateway: gateway)
          resolve_alert
        rescue ::Payments::StandardError => e
          raise ::Payments::StandardError, e.message
        end
      else
        # temporary solution (mock payment) This should happen when request is coming from kiosk app
        payment = object.payments.create(amount: payment_info.pay, status: :success, payment_method: :cash)
      end

      if payment.invalid?
        errors.merge!(payment.errors)
      else
        broadcast_to_parking_spaces
      end
    end

    private

    # Notify dashboard that a session was paid
    def broadcast_to_parking_spaces
      ActionCable.server.broadcast("parking_spaces_channel_#{object.parking_lot.id}",::Api::Dashboard::Parking::SlotSerializer.new(object.parking_slot))
    end

    def payment_gateway
      "payment_gateway/#{gateway}".classify.constantize
    end

    def resolve_alert
      return if object.user.blank?
      object.alerts.where(type: :parking_confirmation, status: :opened).each do |alert|
        transactional_update!(alert, status: :resolved)
      end
    end

  end
end
