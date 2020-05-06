module Parking
  module VehicleRules
    class Create < ApplicationInteraction
      include CreateWithObject

      string :color, default: nil
      string :plate_number, default: nil
      string :vehicle_type, default: nil
      integer :vehicle_id, default: nil
      object :lot, class: 'ParkingLot'

      validates :plate_number, presence: true, unless: -> { vehicle_id? || color? || vehicle_type? }
      validates :color, presence: true, unless: -> { vehicle_id? || plate_number? }
      validates :vehicle_type, presence: true, unless: -> { vehicle_id? || plate_number? }

      def execute
        [:vehicle_id, :plate_number, :attributes].each do |builder|
          if send(builder)
            send("build_with_#{builder}") and break
          end
        end
      end

      private

      def attributes
        color && vehicle_type
      end

      def build_with_vehicle_id
        vehicle = Vehicle.find_by(id: vehicle_id)

        if vehicle
          simple_create(VehicleRule, lot: lot, vehicle_id: vehicle.id)
        else
          errors.add(:vehicle_id, :invalid)
        end
      end

      def build_with_plate_number
        vehicle = Vehicle.find_or_create_by(plate_number: plate_number)

        if vehicle.invalid?
          errors.merge!(vehicle.errors) and return
        end

        simple_create(VehicleRule, lot: lot, vehicle: vehicle)
      end

      def build_with_attributes
        simple_create(VehicleRule, color: color, vehicle_type: vehicle_type, lot: lot)
      end
    end
  end
end
