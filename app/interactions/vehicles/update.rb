module Vehicles
  class Update < ::ApplicationInteraction

    object :vehicle, class: Vehicle
    string :plate_number
    string :color, default: nil
    string :vehicle_type, default: nil
    integer :manufacturer_id
    string :model

    validates :plate_number, :model, :manufacturer_id, presence: true

    def execute
      if vehicle.parking_sessions.current.any?
        errors.add(:base, :has_active_session, vehicle_plate_number: vehicle.plate_number )
      end
      vehicle.update(inputs.except(:vehicle))
      errors.merge!(vehicle.errors) if vehicle.errors.any?
    end
  end
end
