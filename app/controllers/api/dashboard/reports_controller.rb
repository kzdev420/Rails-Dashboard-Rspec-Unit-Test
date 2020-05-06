module Api
  module Dashboard
    class ReportsController < ApplicationController

      api :GET, '/api/dashboard/reports/', 'Get a list of the reports'
      param :name, String, 'Report name', required: false
      param :range, Hash, 'Date Range (all reports created within the selected range)' do
        param :from, Integer, 'From date in timestamp (numeric) format', required: true
        param :to, Integer, 'To date in timestamp (numeric) format', required: true
      end
      param :type, String, 'Report name', required: false
      header :Authorization, 'Auth token from users#sign_in', required: true

      def index
        authorize!
        scope = paginate ::Api::Dashboard::ReportQuery.call(params.merge(user: current_user))
        respond_with scope, each_serializer: ::Api::Dashboard::ReportSerializer
      end

    end
  end
end
