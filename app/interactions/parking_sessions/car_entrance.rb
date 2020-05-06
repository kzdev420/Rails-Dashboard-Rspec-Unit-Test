module ParkingSessions
  class CarEntrance < BaseEvent
    include Logging

    validate do
      # if AI doesn't specify one of following parameters - we shouldn't save session
      unless (plate_number.present? && plate_number != 'NULL') || vehicle_images.any?
        errors.add(:base, :need_more_details)
        throw(:abort)
      end
    end

    def execute
      ActiveRecord::Base.transaction do
        @vehicle = set_vehicle
        raise ActiveRecord::Rollback unless car_session_unique?
        create_session
        save_vehicle_images
        compose(Parking::VehicleRules::Check, vehicle: vehicle)
      end

      return if invalid?

      if vehicle.plate_number.present?
        notify_user
      else
        notify_admin
      end
    end

    def to_model
      session.reload
    end

    private

    def create_session
      attrs = {
        entered_at: Time.at(timestamp),
        vehicle: vehicle,
        ai_status: :entered,
        parking_lot: parking_lot,
        uuid: uuid
      }

      @session = transactional_create!(ParkingSession, attrs)
    end

    def notify_user
      if user = vehicle.user
        UserNotifier.car_entrance(user, session)
      end
    end

    def notify_admin
      ParkingAdminMailer.unrecognized_entrance(parking_lot).deliver_later
    end
  end
end
