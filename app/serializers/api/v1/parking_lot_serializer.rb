module Api
  module V1
    class ParkingLotSerializer < ::ParkingLotSerializer
      attributes :id,
                 :name,
                 :available,
                 :capacity,
                 :rate,
                 :free,
                 :email,
                 :period,
                 :phone,
                 :nearby_places

      has_one :location, serializer: LocationSerializer

      def nearby_places
        object.places.order(distance: :asc).map { |v| Api::V1::PlaceSerializer.new(v) }
      end
    end
  end
end
