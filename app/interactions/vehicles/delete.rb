module Vehicles
  class Delete < ::ApplicationInteraction

    object :vehicle, class: Vehicle

    def execute
      if vehicle.parking_sessions.current.any?
        errors.add(:base, :has_active_session, vehicle_plate_number: vehicle.plate_number )
        return self
      end
      vehicle.update(status: :deleted)
      errors.merge!(vehicle.errors) if vehicle.errors.any?
      self
    end
  end
end
