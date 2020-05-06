module Api
  module Dashboard
    module Parking
      class VehicleRuleSerializer < ApplicationSerializer
        attributes :color, :vehicle, :vehicle_type, :lot

        def vehicle
          object.vehicle&.as_json(only: [:id, :plate_number])
        end

        def lot
          object.lot&.as_json(only: [:id, :name])
        end
      end
    end
  end
end
