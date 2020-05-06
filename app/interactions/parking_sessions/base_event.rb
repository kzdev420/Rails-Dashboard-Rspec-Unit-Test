module ParkingSessions
  class BaseEvent < ::ApplicationInteraction
    attr_reader :session, :vehicle
    alias :object :session

    object :parking_lot, class: ParkingLot
    string :uuid
    integer :timestamp, default: Time.zone.now.to_i
    string :plate_number, default: nil
    string :vehicle_type, default: nil
    string :color, default: nil
    array :parking_images, default: []
    array :vehicle_images, default: []

    set_callback :execute, :after, -> { Ai::Parking::LotStateWorker.perform_async(parking_lot.id) }, if: :valid?

    def execute
      raise('It is abstract class')
    end

    private

    def car_session_unique?
      if active_session = ParkingSession.where(vehicle_id: vehicle.id).where.not(status: :finished).last
        errors.add(:vehicle, :has_active_session, { id: vehicle.id, plate_number: vehicle.plate_number,  parking_lot: active_session.parking_lot.name, uuid: active_session.uuid })
      end
      active_session.blank?
    end

    def save_vehicle_images
      SaveVehicleImagesWorker.perform_async(vehicle.id, vehicle_images, alert_unrecognized_lpn, inputs[:parking_slot_id], inputs[:uuid])
    end

    def initialize_session

      if session.new_record?
        unless (plate_number.present? && plate_number.upcase != 'NULL') || vehicle_images.any?
          errors.add(:base, :need_more_details)
          throw(:abort)
        end

        @vehicle = set_vehicle
        attrs = yield(vehicle)
        throw(:abort) unless car_session_unique?
        @session = transactional_create!(ParkingSession, attrs)
        @session.reload.logs.first.update(comment: I18n.t("parking/log.text.car_entrance_not_tracked"))
      else
        # In case of previous events where the AI didn't detect the plate_number but in following event it does
        # It should update the plate_number and create the car
        @vehicle = set_vehicle
        if vehicle.plate_number.nil? && plate_number.present?
          new_vehicle = Vehicle.find_by(plate_number: plate_number) # If it already exist  assign session to it
          new_vehicle.present? ?  session.update(vehicle_id: new_vehicle.id) : vehicle.update(plate_number: plate_number)
        end
      end
      save_vehicle_images
    end

    def session_finished?
      if session.present? && session.status.to_sym == :finished
        errors.add(:parking_session, :finished)
        return true
      end
    end

    def set_vehicle
      if session.present? && !session.new_record?
        founded = session.vehicle
      elsif plate_number.present?
        founded = Vehicle.find_by(plate_number: plate_number)
      end

      return founded if founded
      attrs = {
        plate_number: plate_number == 'NULL' ? nil : plate_number,  # 'NULL' if AI couldn't recognize plate number
        color: color,
        vehicle_type: vehicle_type
      }
      unless new_vehicle = Vehicle.create!(attrs)
        errors.merge!(new_vehicle.errors)
        throw(:abort)
      end
      new_vehicle
    end

    def set_session
      @session = ParkingSession.find_or_initialize_by(uuid: uuid)
    end

    def set_parking_lot
      # If session already has a parking_lot it should use always its own parking lot
      @parking_lot = session.parking_lot
    end

    def user
      @user ||= session.vehicle.user
    end

    def should_abort?
      throw(:abort) if errors.any?
    end

    # Notify if LPN is unrecognized when a car is parking between 7:00am and 7:00pm
    def alert_unrecognized_lpn
      Time.zone = parking_lot.time_zone
      action_name = self.class.name.demodulize.underscore
      action_name == 'car_parked' && session.vehicle.plate_number.nil? && (Time.current.hour >= 7 && Time.current.hour < 19)
    end

  end
end