module Api
  module Dashboard
    class ParkingSlotsController < ::Api::Dashboard::ApplicationController
      wrap_parameters :parking_slot

      api :GET, '/api/dashboard/parking_lot/:parking_lot_id/parking_slots', 'Parking slots list'
      header :Authorization, 'Auth token', required: true
      param :parking_lot_id, String, 'Parking lot ID', required: true

      def index
        scope = ParkingSlot.where(parking_lot_id: params[:parking_lot_id]).order("id DESC")
        respond_with scope, each_serializer: ::Api::Dashboard::Parking::SlotSerializer
      end

    end
  end
end
