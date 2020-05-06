module Api
  module V1
    class ParkingLotsController < ::Api::V1::ApplicationController
      # before_action :authenticate_user!

      api :GET, '/api/v1/parking_lots', 'Parking lots list'
      param :per_page, Integer, 'Items per page, default is 10. Check response headers for total count (key: X-Total)'
      param :page, Integer, 'Items page'
      param :location_radius, Hash do
        param :distance, Float, 'In miles (default is 10 miles)', required: false
        param :ltd, Float, required: false
        param :lng, Float, required: false
      end
      header :Authorization, 'Auth token from users#sign_in', required: true

      def index
        scope = paginate ::Api::V1::ParkingLotsQuery.call(params)
        respond_with scope, each_serializer: ::Api::V1::ParkingLotPreviewSerializer
      end

      api :GET, '/api/v1/parking_lots/:id', 'Parking lot details'
      param :id, Integer, 'Parking lot id', required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      def show
        record = ParkingLot.find(params[:id])
        respond_with record, serializer: ::Api::V1::ParkingLotSerializer
      end
    end
  end
end
