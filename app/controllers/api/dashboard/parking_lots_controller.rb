module Api
  module Dashboard
    class ParkingLotsController < ::Api::Dashboard::ApplicationController
      wrap_parameters :parking_lot,
                      include: ParkingLot.attribute_names +
                        [:setting, :location, :parking_admin_id, :town_manager_id, :places, :rules]

      api :GET, '/api/dashboard/parking_lots', 'Parking lots list'
      header :Authorization, 'Auth token', required: true
      param :per_page, Integer, 'Items per page count, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page number', required: false
      param :id, Integer, 'Filter by parking lot ID', required: false
      param :query, Hash, "Hash query to filter parking lot" do
        param :parking_lots, Hash, "Filter by" do
          param :email, String, required: false
          param :name, String, required: false
          param :phone, String, required: false
        end
        param :location, Hash, "Filter by" do
          param :full_address, String, required: false
        end
      end
      param :status, ParkingLot.statuses.keys, "Filter by status", required: false
      param :town_managers, Array, "Filter by array of town manager IDs", required: false
      param :parking_admins, Array, "Filter by array of parking admin IDs", required: false
      param :available_cameras, Integer, "Filter by amount of camera associated to parking lot"
      param :order, Hash, 'Hash order' do
        param :keyword, ParkingLot.attribute_names + [:available_cameras], "Order keyword", required: false
        param :direction, ['asc', 'desc'], "Order Direction", required: false
      end

      def index
        scope = paginate ::Api::Dashboard::ParkingLotQuery.call(params.merge(user: current_user))
        respond_with scope, each_serializer: ::Api::Dashboard::Parking::LotSerializer
      end

      api :POST, '/api/dashboard/parking_lots', 'Create parking lot'
      header :Authorization, 'Auth token', required: true
      param :parking_lot, Hash do
        param :name, String, required: true
        param :email, String, required: true
        param :phone, String, required: true
        param :parking_admin_id, Integer, 'ID of user having parking admin role', required: true
        param :town_manager_id, Integer, 'ID of user having town manager role', required: true
        param :avatar, String, 'File or base64', required: true
        param :status, Admin.statuses.keys, required: true
        param :outline, String, 'base64 json string'
        param :allow_save, Integer, 'Parking lot creation can be made on several steps', required: false
        param :location, Hash, required: true do
          param :city, String, required: true
          param :street, String, required: true
          param :building, String, required: true
          param :country, String, required: true
          param :zip, String, required: true
          param :lng, :number, required: true
          param :ltd, :number, required: true
        end
        param :setting, Hash do
          param :rate, Float
          param :parked, Integer
          param :overtime, Integer
          param :period, Integer
        end
      end

      def create
        authorize! ParkingLot
        payload = params.fetch(:parking_lot, {})
        result = ::ParkingLots::Create.run(payload.merge(allow_save: params[:allow_save]))
        respond_with result, serializer: ::Api::Dashboard::DetailedParkingLotSerializer
      end

      api :PUT, '/api/dashboard/parking_lots/:id', 'Update parking lot (specify only fields we want to update)'
      param :id, Integer, required: true
      header :Authorization, 'Auth token', required: true
      param :parking_lot, Hash do
        param :name, String, required: false
        param :email, String, required: false
        param :phone, String, required: false
        param :parking_admin_id, Integer, 'ID of user having parking admin role', required: false
        param :town_manager_id, Integer, 'ID of user having town manager role', required: false
        param :status, Admin.statuses.keys, required: false
        param :avatar, String, 'File or base64', required: false
        param :outline, String, 'base64 json string'
        param :location, Hash, 'Only if we want to update current location', required: false do
          param :city, String, required: true
          param :street, String, required: true
          param :building, String, required: true
          param :country, String, required: true
          param :zip, String, required: true
          param :lng, :number, required: true
          param :ltd, :number, required: true
        end
        param :setting, Hash do
          param :rate, Float
          param :parked, Integer
          param :overtime, Integer
          param :period, Integer
        end
      end

      def update
        lot = ParkingLot.find(params[:id])
        authorize! lot
        payload = params.fetch(:parking_lot, {}).merge(object: lot, role: current_user.role.name)
        result = ::ParkingLots::Update.run(payload)
        respond_with result, serializer: ::Api::Dashboard::DetailedParkingLotSerializer
      end

      api :GET, '/api/dashboard/parking_lots/:id', 'Fetch parking lot details'
      param :id, Integer, required: true
      header :Authorization, 'Auth token', required: true

      def show
        lot = ParkingLot.find(params[:id])
        authorize! lot
        respond_with lot, serializer: ::Api::Dashboard::Parking::LotSerializer
      end

      private

      def per_page
        params[:per_page] || 20
      end
    end
  end
end
