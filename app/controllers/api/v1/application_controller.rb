module Api
  module V1
    class ApplicationController < ::Api::ApplicationController
      before_action :store_tracker_id

      private

      def store_tracker_id
        return if current_user.nil? || request.headers['psad-tracker-id'].nil?
        return if current_user.trackers.include?(request.headers['psad-tracker-id'])
        @current_user.trackers.push(request.headers['psad-tracker-id'])
        @current_user.save
      end

      def authenticate_user!
        return unauthorized! unless current_user
        return unconfirmed_user! unless current_user.confirmed?
      end

      def current_user
        @current_user ||= Authorizer.authorize_by_token(request.headers['Authorization'], User)
      end

      def parking_lot
        @parking_lot ||= begin
          lot_id = params[:parking_lot_id]
          lot = if lot_id.present?
            ParkingLot.active.find_by(id: lot_id)
          else
            ParkingLot.active.first
          end
        end
      end
    end
  end
end
