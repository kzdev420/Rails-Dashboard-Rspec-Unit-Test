module Api
  module V1
    module Ai
      class VehicleSerializer < ::ApplicationSerializer
        attributes :vehicle_id, :plate_number, :color, :vehicle_type, :images
        belongs_to :manufacturer, serializer: ::ManufacturerSerializer

        def vehicle_id
          object.id
        end

        def images
          object.images.map { |image| url_for(image) }
        end
      end
    end
  end
end
