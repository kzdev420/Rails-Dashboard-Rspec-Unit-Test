module Api
  module V1
    class AlertsController < ApplicationController
      # before_action :authenticate_user!

      api :GET, '/api/v1/alerts', 'Alerts list'
      param :per_page, Integer, 'Items per page, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page', required: false
      header :Authorization, 'Auth token from users#sign_in', required: true

      def index
        scope = current_user.alerts.where(status: :opened)
        respond_with paginate(scope).as_json(only: [:id, :type, :subject_id])
      end

      api :GET, '/api/v1/alerts/:id/resolve', 'Alert resolve'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def resolve
        current_user.alerts.find(params[:id]).resolved!
        head :ok
      end
    end
  end
end
