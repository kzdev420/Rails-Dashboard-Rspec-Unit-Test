module Api
  module V1
    class ParkingSessionsController <  ApplicationController
      # before_action :authenticate_user!

      api :GET, '/api/v1/parking_sessions', 'Get user parking session previews list'
      param :per_page, Integer, 'Items per page, default is 10. Check response headers for total count (key: X-Total)', required: false
      header :Authorization, 'Auth token from users#sign_in', required: true

      def index
        respond_with paginate(scope), each_serializer: serializer
      end

      api :GET, '/api/v1/parking_sessions/current', 'Get user current parking session'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def current
        return not_found! unless current_session
        respond_with current_session, serializer: serializer
      end

      api :GET, '/api/v1/parking_sessions/:id/payment', 'Payment calculator'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :check_out, Integer, 'Expected check out time in seconds'

      def payment
        session = ParkingSession.find(params[:id])
        authorize! session
        session.check_out = Time.at(params[:check_out].to_i) if params[:check_out].present?
        respond_with session, serializer: PaymentInfoSerializer
      end

      api :GET, '/api/v1/parking_session/:id', 'Get user parking session details'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :id, Integer, 'Parking session id', required: true

      def show
        session = scope.find(params[:id])
        respond_with session, serializer: serializer
      end

      api :GET, '/api/v1/parking_sessions/recent', 'Get last 5 parking history'
      param :per_page, Integer, 'Items per page, default is 10. Check response headers for total count (key: X-Total)', required: false
      header :Authorization, 'Auth token from users#sign_in', required: true

      def recent
        recent_scope = paginate scope.finished.where.not(check_in: nil).order(check_in: :desc)
        respond_with recent_scope, each_serializer: serializer
      end

      api :POST, '/api/v1/parking_sessions/:id/pay', 'Pay for the parking session'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :check_out, Integer, 'Expected check out time in seconds', required: true
      param :gateway, ['cardconnect'], 'Gateway name to use',  required: false
      param :gateway_params, Hash, 'Params related to the payment information', required: false do
        param :production, [0, 1], '1 indicate that the payment will be using the real credit cards, so it will create a real charge to the card', required: false
        param :set_credit_card_as_default, [0, 1], '1 indicate that the credit card will be set as default for the acocunt', required: false
        param :digital_wallet_attributes, Hash, 'New credit card', required: false do
          param :encryptionhandler, ['EC_GOOGLE_PAY', 'EC_APPLE_PAY'], 'Credit card number', required: true
          param :devicedata, String, 'String returned by mobile app request', required: true
        end
        param :token, String, 'Token provided by cardsecure connect endpoint', required: false
        param :credit_card_id, String, 'Credit card ID associated to a user (This should be provided if the user wants to pay with a stored credit_card)', required: false
        param :credit_card_attributes, Hash, 'New credit card', required: false do
          param :number, String, 'Credit card number', required: true
          param :cvv, String, 'Credit card cvv ', required: true
          param :holder_name, String, 'Credit card holder name ', required: true
          param :expiration_year, String, 'Credit card expiration year', required: true
          param :expiration_month, String, 'Credit card expiration month ', required: true
          param :should_store, [0, 1], 'Indicate if the provided credit card should be associated to the user account', requried: true
        end
        param :last_credit_card_digits, String, 'Last 4 digits when using Apple pay', required: false
      end

      def pay
        session = ParkingSession.with_preloaded.find(params[:id])
        authorize! session
        result = ParkingSessions::Confirm.run(
          object: session,
          check_out: params.dig(:check_out),
          gateway: params.dig(:gateway),
          gateway_params: params.fetch(:gateway_params, {}).to_unsafe_hash
        )
        respond_with result, serializer: serializer
      end

      private

      def serializer
        Api::V1::ParkingSessionSerializer
      end

      def current_session
        @current_session ||= scope.current.where(parking_slot_id: parking_lot.parking_slot_ids).last
      end

      def scope
        ParkingSession.with_preloaded.where(vehicle_id: current_user.vehicle_ids)
      end

      def parking_lot
        @parking_lot ||= ParkingLot.first # temp
      end
    end
  end
end
