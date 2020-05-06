module Api
  module V1
    module Ai
      class ParkingSlotSerializer < ::ApplicationSerializer
        attributes :id, :status

        def id
          object.name
        end
      end
    end
  end
end
