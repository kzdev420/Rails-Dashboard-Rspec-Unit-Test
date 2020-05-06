module Api
  module V1
    class ThinVehicleSerializer < ::ApplicationSerializer
      attributes :id, :plate_number

      def plate_number
        object.plate_number&.upcase
      end

    end
  end
end
