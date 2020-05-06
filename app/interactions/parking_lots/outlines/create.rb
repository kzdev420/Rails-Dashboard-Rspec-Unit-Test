module ParkingLots
  module Outlines
    class Create < ApplicationInteraction
      include CreateWithObject

      array :spaces do
        hash do
          string :space_id
        end
      end

      object :object, class: ParkingLot

      # TODO: rest of the config.parking json attributes' filters can be added later

      def execute
        object.transaction(requires_new: true) do # to make sure parent transaction will be rolled back in case of exception
          spaces.each do |space|
            space_id = space['space_id']
            prefix, name = ParkingSlot.name_with_prefix(space_id)
            zone = if name
              transactional_create!(Parking::Zone, lot: object, name: prefix)
            end

            transactional_create!(ParkingSlot, parking_lot: object, name: space_id, zone: zone)
          end
        end
      end
    end
  end
end
