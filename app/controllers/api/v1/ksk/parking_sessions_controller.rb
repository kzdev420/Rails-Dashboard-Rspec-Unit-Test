module Api
  module V1
    module Ksk
      class ParkingSessionsController < ::Api::V1::Ksk::ApplicationController

        before_action :find_session_by_id, except: [:index]

        api :GET, '/api/v1/ksk/parking_sessions', 'Retrieve active parking session by specified plate number or parking slot (space) id'
        header :Authorization, 'Auth token for Kiosk module', required: true
        param :plate_number, String, 'Car plate number', required: false
        param :parking_slot_id, Integer, 'Parking slot id', required: false
        param :parking_lot_id, Integer, 'Parking lot ID, if not specified - will use default parking lot', required: false

        def index
          return session_not_found! unless @session = set_session
          return session_with_ticket!(:exceeding_grace_period) if ticket_issued?
          respond_with @session, serializer: serializer
        end

        api :PUT, '/api/v1/ksk/parking_sessions/:id/confirm', 'Confirm parking session'
        header :Authorization, 'Auth token for Kiosk module', required: true
        param :id, Integer, 'Parking session id', required: true
        param :parking_session, Hash do
          param :check_out, Integer, 'When user is going to leave parking lot (in seconds)', required: true
        end

        def confirm
          return session_not_found! unless @session
          result = ::ParkingSessions::Confirm.run(
            object: @session,
            kiosk: current_kiosk,
            check_out: params.dig(:parking_session, :check_out)
          )
          respond_with result, serializer: serializer
        end

        api :GET, '/api/v1/ksk/parking_sessions/:id/payment', 'Payment calculator'
        header :Authorization, 'Auth token for Kiosk module', required: true
        param :check_out, Integer, 'Expected check out time in seconds'

        def payment
          return session_not_found! unless @session
          @session.check_out = Time.at(params[:check_out].to_i) if params[:check_out].present?
          respond_with @session, serializer: PaymentInfoSerializer
        end

        desc = <<~HEREDOC
          Retrieve parking session by session ID. Session ID can be taken from /dashboard/ksk/parking_sessions
        HEREDOC
        api :GET, '/api/v1/ksk/parking_sessions/:id', desc
        header :Authorization, 'Auth token for Kiosk module', required: true
        param :id, Integer, required: true

        def show
          return session_not_found! unless @session
          respond_with @session, serializer: serializer
        end

        private

        def serializer
          ::Api::V1::Ksk::ParkingSessionSerializer
        end

        def find_session_by_id
          @session = ParkingSession.with_preloaded.find_by(id: params[:id])
        end

        def set_session
          slot_id, plate, lot_id = params[:parking_slot_id], params[:plate_number], params[:parking_lot_id]

          lot = ParkingLot.find_by(id: lot_id) || ParkingLot.last # temp while we have

          return unless lot

          if slot_id.present? && by_slot = (lot.parking_slots.where(name: slot_id)).first
            # Take the last session to check if it's still active (created status)
            session = by_slot.parking_sessions.with_preloaded.where(status: :created).last
          end

          if plate.present? && by_plate = Vehicle.find_by(plate_number: plate)
            # Take the last session to check if it's still active (created status)
            session = by_plate.parking_sessions.with_preloaded.where(parking_slot_id: lot.parking_slot_ids, status: :created).last
          end

          session
        end

        def ticket_issued?
          violation = @session.violations.joins(:rule).where(parking_rules: { name: ::Parking::Rule.names[:exceeding_grace_period] }).first
          return false if violation.nil?
          return violation.ticket.issued?
        end
      end
    end
  end
end
