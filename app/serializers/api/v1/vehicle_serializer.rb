module Api
  module V1
    class VehicleSerializer < ::ApplicationSerializer
      attributes :id, :plate_number, :vehicle_type, :color, :model, :user_id
      belongs_to :manufacturer, serializer: ::ManufacturerSerializer

      def plate_number
        object.plate_number&.upcase
      end
    end
  end
end
