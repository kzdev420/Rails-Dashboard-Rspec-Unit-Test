module Parking
  module VehicleRules
    class Update < ApplicationInteraction
      string :color, default: nil
      string :plate_number, default: nil
      string :vehicle_type, default: nil
      integer :vehicle_id, default: nil
      object :object, class: '::Parking::VehicleRule'

      def execute
        object.update(filled_inputs)
      end
    end
  end
end
