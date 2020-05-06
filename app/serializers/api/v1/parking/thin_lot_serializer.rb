module Api
  module V1
    module Parking
      class ThinLotSerializer < ::ApplicationSerializer
        attributes :id, :name, :rate, :period
        has_one :location, serializer: ThinLocationSerializer

        def rate
          object.setting&.rate
        end

        def period
          ::ParkingLot::PERIOD_NORMALIZER
        end
      end
    end
  end
end
