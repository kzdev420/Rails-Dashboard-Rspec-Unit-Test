module Api
  module V1
    module Ksk
      class ParkingLotsController < ::Api::V1::Ksk::ApplicationController
        before_action :set_parking_lot, only: %i[show]

        api :GET, "/api/v1/ksk/parking_lots", "List: all parking lots in the system"

        def index
          @parking_lots = ParkingLot.includes(:location, :setting).active
          respond_with @parking_lots, each_serializer: ::Api::V1::Ksk::ParkingLotSerializer
        end

        desc = <<~HEREDOC
         Get parking lot state. For now just use any integer ID: from /dashboard/ksk/parking_lots.
         This parking lot ID should be ENV variable for each Kiosk.
        HEREDOC
        api :GET, "/api/v1/ksk/parking_lots/:id", desc
        param :id, Integer, "Parking lot id", required: true

        def show
          respond_with @parking_lot, serializer: ::Api::V1::Ksk::ParkingLotSerializer, with_slots: true
        end

        private

        def set_parking_lot
          @parking_lot = ParkingLot.active.find_by(id: params[:id]) || ParkingLot.active.last # temp while we have only on Parking
          raise ActiveRecord::RecordNotFound unless @parking_lot
        end

        def parking_lot_params
          params.fetch(:parking_lot).permit(:address, :rate)
        end
      end
    end
  end
end
