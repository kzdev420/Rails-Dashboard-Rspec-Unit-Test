module Api
  module V1
    class ParkingLotPreviewSerializer < ::ParkingLotSerializer
      attributes :id, :name, :available, :capacity, :rate, :period
      has_one :location, serializer: LocationSerializer

    end
  end
end
