module ParkingSessions
  class CarParked < BaseEvent
    include Logging

    attr_reader :slot

    string :parking_slot_id

    validate :should_abort?

    set_callback :validate, :before, -> do
      return if session.present? # Avoid execute mutliple times when validations happen
      set_session
      initialize_session do |vehicle|
        {
          vehicle: vehicle,
          parking_lot: parking_lot,
          entered_at: Time.at(timestamp),
          uuid: uuid
        }
      end
      set_parking_slot
      set_parking_lot
    end

    def execute
      return if session_finished?

      if slot.occupied?
        errors.add(:parking_slot_id, :occupied)
      else
        bind_session_and_slot
        if valid? && user = session.vehicle.user
          UserNotifier.car_parked(user, session)
        end
      end
    end

    private

    def bind_session_and_slot
      ActiveRecord::Base.transaction do
        attributes = {
          parking_slot: slot,
          parked_at: Time.at(timestamp),
          ai_status: :parked,
          check_out: Time.at(timestamp + parking_lot.period)
        }

        if session.cancelled? # After a session is cancelled if decide to park again in another slot it should be able to do it
          attributes.merge!(status: :created)
        end

        if session.vehicle.user
          attributes.merge!(fee_applied: session.rate)
        end

        attributes.merge!(check_in: Time.at(timestamp)) if session.check_in.blank?

        unless session.update(attributes)
          errors.merge!(session.errors)
          raise ActiveRecord::Rollback
        end

        unless slot.update(status: :occupied)
          errors.merge!(slot.errors)
          raise ActiveRecord::Rollback
        end

        create_alert
        broadcast_to_parking_spaces
        Ai::Parking::GracePeriodViolationWorker.start_counter(session)
      end
    end

    def create_alert
      return if user.blank?
      transactional_create!(Alert, subject: session, user: session.vehicle.user)
    end

    def set_parking_slot
      unless @slot = (parking_lot.parking_slots.find_by(name: parking_slot_id))
        errors.add(:parking_slot_id, :not_found)
        throw(:abort)
      end
    end

    def broadcast_to_parking_spaces
      ActionCable.server.broadcast("parking_spaces_channel_#{parking_lot.id}",::Api::Dashboard::Parking::SlotSerializer.new(slot))
    end
  end
end
