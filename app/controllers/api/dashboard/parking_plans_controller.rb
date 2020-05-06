module Api
  module Dashboard
    class ParkingPlansController < ::Api::Dashboard::ApplicationController

      api :POST, '/api/dashboard/parking_lots/:parking_lot_id/parking_plans', 'Update Parking Lot Layout Map'
      param :parking_lot_id, Integer, required: true
      param :parking_plan_image, String, 'File or base64', required: true
      param :name, String, "File name to display", required: true
      header :Authorization, 'Auth token', required: true

      def create
        lot = ParkingLot.find(params[:parking_lot_id])
        authorize! lot, with: ParkingPlanPolicy
        result = ::ParkingLots::ParkingPlan::Create.run(name: params[:name], parking_plan_image: params[:parking_plan_image], object: lot)
        respond_with result, serializer: Api::Dashboard::Parking::LotSerializer
      end

      api :PUT, '/api/dashboard/parking_lots/:parking_lot_id/parking_plans/:id', 'Update Parking Plan Coordinate associated to Parking lot'
      api :PATCH, '/api/dashboard/parking_lots/:parking_lot_id/parking_plans/:id', 'Update Parking Plan Coordinate associated to Parking lot'
      param :parking_lot_id, Integer, required: true
      param :id, Integer, required: true
      param :parking_plan_coordinates, Array, required: false
      param :parking_plan_image, String, required: false
      param :name, String, required: false
      header :Authorization, 'Auth token', required: true

      def update
        lot = ParkingLot.find(params[:parking_lot_id])
        authorize! lot, with: ParkingPlanPolicy
        result = ::ParkingLots::ParkingPlan::Update.run(
          parking_plan_coordinates: params[:parking_plan_coordinates],
          parking_plan_image: params[:parking_plan_image],
          name: params[:name],
          object: lot,
          parking_plan_id: params[:id])
        respond_with lot, serializer: Api::Dashboard::Parking::LotSerializer
      end

      api :DELETE, '/api/dashboard/parking_lots/:parking_lot_id/parking_plans/:id', 'Destroy Parking Space associated to Parking lot'
      param :parking_lot_id, Integer, required: true
      param :id, Integer, required: true
      header :Authorization, 'Auth token', required: true

      def destroy
        lot = ParkingLot.find(params[:parking_lot_id])
        authorize! lot, with: ParkingPlanPolicy
        result = ::ParkingLots::ParkingPlan::Delete.run(id: params[:id], object: lot)
        respond_with lot, serializer: Api::Dashboard::Parking::LotSerializer
      end

    end
  end
end
