module Api
  module V1
    module Ai
      class ParkingSessionSerializer < ::ParkingSessionSerializer
        attributes :session_id,
          :uuid,
          :images,
          :vehicle,
          :check_in,
          :check_out,
          :created_at,
          :parking_slot_id,
          :parking_lot_id

        def session_id
          object.id
        end

        def check_in
          object.check_in.to_i
        end

        def created_at
          object.created_at.to_i
        end

        def parking_slot_id
          object.parking_slot&.name
        end

        def images
          object.images.map { |image| url_for(image) }
        end

        def vehicle
          VehicleSerializer.new(object.vehicle)
        end
      end
    end
  end
end
