module Api
  module Dashboard
    class RolesController < ApplicationController
      api :GET, '/api/dashboard/roles', 'Roles list'
      header :Authorization, 'Auth token', required: true
      param :per_page, Integer, 'Items per page count, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page number', required: false

      def index
        authorize!
        respond_with paginate(Role.all), each_serializer: RoleSerializer
      end
    end
  end
end
