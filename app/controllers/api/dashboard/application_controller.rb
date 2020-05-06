module Api
  module Dashboard
    class ApplicationController < ::Api::ApplicationController
      before_action :authenticate_admin!
      before_action :set_paper_trail_whodunnit
      before_action :store_tracker_id

      def authenticate_admin!
        return unauthorized! unless current_user
        return account_suspended! unless current_user.active?
      end

      def current_user
        @current_user ||= Authorizer.authorize_by_token(request.headers['Authorization'], Admin)
      end

      private

      def store_tracker_id
        return if current_user.nil? || request.headers['psad-tracker-id'].nil?
        return if current_user.trackers.include?(request.headers['psad-tracker-id'])
        @current_user.trackers.push(request.headers['psad-tracker-id'])
        @current_user.save
      end
    end
  end
end
