module Api
  module Dashboard
    class ParkingSessionsController < ::Api::Dashboard::ApplicationController
      skip_before_action :authenticate_admin!, only: [:report]
      wrap_parameters :parking_sessions

      api :GET, '/api/dashboard/parking_sessions', 'Parking session list'
      header :Authorization, 'Auth token', required: true
      param :parking_lot_id, String, 'Parking lot ID', required: true
      param :parking_session_id, String, 'Parking session ID', required: false
      param :payments, Payment.payment_methods.keys, "Filter by Session attributes"
      param :statuses, ParkingSession.statuses.keys, 'Status of the Parking sessions', required: false
      param :user_ids, Array, 'User IDs associated to parking sessions', required: false
      param :kiosk_ids, String, 'Kiosk IDs associated to parking sessions', required: false
      param :created_at, Hash, 'When the session was created', required: false do
        param :from, String, "Date formatted %Y-%-m-%-d", required: false
        param :to, String, "Date formatted %Y-%-m-%-d", required: false
      end
      param :check_in, Hash, 'When the car parked', required: false do
        param :from, String, "Date formatted %Y-%-m-%-d", required: false
        param :to, String, "Date formatted %Y-%-m-%-d", required: false
      end
      param :check_out, Hash, 'When the car left the parking lot', required: false do
        param :from, String, "Date formatted %Y-%-m-%-d", required: false
        param :to, String, "Date formatted %Y-%-m-%-d", required: false
      end
      param :slot_name, String, "Slot name", required: false
      param :fee_applied, String, 'Price by hour charged to the user', required: false
      param :total_price, String, 'Total price charged to the user', required: false

      param :query, Hash, "Hash query to filter parking sessions", required: false do
        param :vehicles, Hash, "Filter by Vehicle attributes" do
          param :plate_number, String, 'Vehicle plate number', required: false
        end
      end

      def index
        authorize! ParkingLot.find(params[:parking_lot_id]), to: :show?
        scope = paginate ::Api::Dashboard::ParkingSessionQuery.call(params)
        respond_with scope, each_serializer: ::Api::Dashboard::Parking::SessionSerializer
      end

      api :GET, '/api/dashboard/parking_sessions/:id', 'Parking session by ID'
      header :Authorization, 'Auth token', required: true
      param :id, String, 'Parking session ID', required: true

      def show
        session = ParkingSession.find(params[:id])
        authorize! session
        respond_with session, serializer: ::Api::Dashboard::Parking::SessionSerializer
      end

      api :GET, '/api/dashboard/parking_sessions/report', 'Excel file with session data'
      header :Authorization, 'Auth token', required: true
      param :parking_lot_id, String, 'Parking lot ID', required: true
      param :parking_session_id, String, 'Parking session ID', required: false
      param :payments, Payment.payment_methods.keys, "Filter by Session attributes"
      param :statuses, ParkingSession.statuses.keys, 'Status of the Parking sessions', required: false
      param :user_ids, Array, 'User IDs associated to parking sessions', required: false
      param :kiosk_ids, String, 'Kiosk IDs associated to parking sessions', required: false
      param :created_at, Hash, 'When the session was created', required: false do
        param :from, String, "Date formatted %Y-%-m-%-d", required: false
        param :to, String, "Date formatted %Y-%-m-%-d", required: false
      end
      param :check_in, Hash, 'When the car parked', required: false do
        param :from, String, "Date formatted %Y-%-m-%-d", required: false
        param :to, String, "Date formatted %Y-%-m-%-d", required: false
      end
      param :check_out, Hash, 'When the car left the parking lot', required: false do
        param :from, String, "Date formatted %Y-%-m-%-d", required: false
        param :to, String, "Date formatted %Y-%-m-%-d", required: false
      end
      param :slot_name, String, "Slot name", required: false
      param :fee_applied, String, 'Price by hour charged to the user', required: false
      param :total_price, String, 'Total price charged to the user', required: false

      param :query, Hash, "Hash query to filter parking sessions", required: false do
        param :vehicles, Hash, "Filter by Vehicle attributes" do
          param :plate_number, String, 'Vehicle plate number', required: false
        end
      end

      def report
        @current_user ||= Authorizer.authorize_by_token(params[:token], Admin)
        return unauthorized! unless current_user
        return account_suspended! unless current_user.active?
        authorize! ParkingLot.find(params[:parking_lot_id]), to: :show?
        @sessions = ::Api::Dashboard::ParkingSessionQuery.call(params)

        respond_to do |format|
          format.xlsx { render xlsx: @sessions, filename: 'Transaction Records' }
        end
      end

    end
  end
end
