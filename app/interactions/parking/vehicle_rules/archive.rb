module Parking
  module VehicleRules
    class Archive < ApplicationInteraction
      object :lot, class: 'ParkingLot'
      array :rule_ids do
        integer
      end

      def execute
        VehicleRule.transaction do
          lot.vehicle_rules.find(rule_ids).each do |rule|
            transactional_update!(rule, status: :archived)
          end
        end
      end
    end
  end
end
