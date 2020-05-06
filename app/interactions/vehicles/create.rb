module Vehicles
  class Create < ApplicationInteraction
    attr_reader :vehicle

    object :user, class: User
    string :plate_number
    string :color, default: nil
    string :vehicle_type, default: nil
    integer :manufacturer_id
    string :model

    validates :plate_number, :model, :manufacturer_id, presence: true

    def execute
      if user.active_vehicles.count >= User::VEHICLES_MAX_COUNT
        errors.add(:base, :more_than_max_count)
        return self
      end

      @vehicle = user.vehicles.find_by(status: :deleted, plate_number: plate_number)

      # If a vehicle with the same plate_number already existed and it was 'deleted'
      if @vehicle.present?
        @vehicle.update(vehicle_params.merge(status: :active, user_id: user.id))
      else
        @vehicle = Vehicle.find_by(plate_number: plate_number)

        if @vehicle.present?
          if @vehicle.user_id.present?
            errors.add(:base, :already_taken_by_another_account, { plate_number: plate_number })
            return self
          end
          @vehicle.update(vehicle_params.merge(user_id: user.id))
        else
          @vehicle = user.vehicles.create(vehicle_params)
        end
      end
      errors.merge!(vehicle.errors) if vehicle.errors.any?
      self
    end

    def to_model
      vehicle.reload
    end

    def vehicle_params
      inputs.slice(:plate_number, :color, :vehicle_type, :manufacturer_id, :model)
    end

  end
end
