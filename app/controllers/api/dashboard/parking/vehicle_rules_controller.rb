module Api
  module Dashboard
    module Parking
      class VehicleRulesController < ApplicationController
        api :GET, '/api/dashboard/parking/lots/:lot_id/vehicles_rules'
        header :Authorization, 'Auth token', required: true
        param :per_page, Integer, 'Items per page count, default is 10. Check response headers for total count (key: X-Total)', required: false
        param :page, Integer, 'Items page number', required: false

        def index
          authorize! ::Parking::VehicleRule
          lot = ParkingLot.find(params[:lot_id])
          scope = lot.vehicle_rules.where.not(status: :archived)
          respond_with paginate(scope), each_serializer: VehicleRuleSerializer
        end

        api :POST, '/api/dashboard/parking/lots/:lot_id/vehicle_rules'
        header :Authorization, 'Auth token', required: true
        param :vehicle_rule, Hash, required: true do
          param :color, String, 'Vehicle color'
          param :plate_number, String, 'Vehicle plate number'
          param :vehicle_type, String, 'Vehicle type'
          param :vehicle_id, Integer, 'Vehicle id'
        end

        def create
          authorize! ::Parking::VehicleRule
          payload = params.fetch(:vehicle_rule, {}).merge(lot: ParkingLot.find(params[:lot_id]))
          outcome = ::Parking::VehicleRules::Create.run(payload)
          respond_with outcome, serializer: VehicleRuleSerializer
        end

        api :PUT, '/api/dashboard/parking/lots/:lot_id/vehicle_rules/archive'
        header :Authorization, 'Auth token', required: true
        param :rule_ids, Array, of: Integer, desc: "Array of rules' ids"

        def archive
          authorize! ::Parking::VehicleRule
          outcome = ::Parking::VehicleRules::Archive.run(
            lot: ParkingLot.find(params[:lot_id]),
            rule_ids: params[:rule_ids]
          )
          respond_with outcome.result, each_serializer: VehicleRuleSerializer
        end

        api :PUT, '/api/dashboard/parking/lots/:lot_id/vehicle_rules/:id'
        header :Authorization, 'Auth token', required: true
        param :vehicle_rule, Hash, required: true do
          param :color, String, 'Vehicle color'
          param :plate_number, String, 'Vehicle plate number'
          param :vehicle_type, String, 'Vehicle type'
          param :vehicle_id, Integer, 'Vehicle id'
        end

        def update
          rule = ::Parking::VehicleRule.find(params[:id])
          authorize! rule
          payload = params.fetch(:vehicle_rule, {}).merge(object: rule)
          outcome = ::Parking::VehicleRules::Update.run(payload)
          respond_with outcome, serializer: VehicleRuleSerializer
        end
      end
    end
  end
end
