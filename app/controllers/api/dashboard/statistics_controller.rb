module Api
  module Dashboard
    class StatisticsController < ApplicationController
      api :GET, '/api/dashboard/statistics', 'Statitics Report'
      header :Authorization, 'Auth token', required: true
      param :type, ['vehicle'], '', required: true
      param :parking_lot_ids, Array, 'Array of parking lots ID, if empty it will include all'
      param :range, Hash, 'Date Range (calculated within the selected range)' do
        param :from, Integer, 'From date in timestamp (numeric) format', required: true
        param :to, Integer, 'To date in timestamp (numeric) format', required: true
      end
      param :vehicle_parked, Hash do
      end

      def index
        payload = interactor.run(params.merge(current_user: current_user))
        render json: payload.result
      end

      private
      def interactor
        "statistics/#{params[:type]}".classify.constantize
      end
    end
  end
end
