module Api
  module V1
    module Ksk
      class ParkingSessionSerializer < ::ParkingSessionSerializer
        attributes :id,
          :check_in,
          :check_out,
          :created_at,
          :slot,
          :paid,
          :total_price

        belongs_to :parking_lot, key: :lot, serializer: Api::V1::Ksk::Parking::ThinLotSerializer
        belongs_to :vehicle, serializer: ThinVehicleSerializer

        def slot
          { id: parking_slot.name } if parking_slot
        end

        def total_price
          payment_info.pay
        end
      end
    end
  end
end
