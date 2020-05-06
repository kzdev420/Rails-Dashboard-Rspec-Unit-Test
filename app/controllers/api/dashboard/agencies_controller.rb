module Api
  module Dashboard
    class AgenciesController < ::Api::Dashboard::ApplicationController
      wrap_parameters :agency, include: Agency.attribute_names + %i[location manager_id officer_ids town_manager_id]

      api :GET, '/api/dashboard/agencies', 'Get agencies list'
      header :Authorization, 'Auth token', required: true
      param :per_page, Integer, 'Items per page count, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page number', required: false
      param :status, Agency.statuses.keys, required: false
      param :query, String, 'Query (can be substring of name, full address, email or phone)', required: false

      def index
        scope = paginate ::Api::Dashboard::AgenciesQuery.call(params.merge(user: current_user))
        respond_with scope, each_serializer: ::Api::Dashboard::AgencySerializer
      end

      api :POST, '/api/dashboard/agencies', 'Create new agency'
      header :Authorization, 'Auth token', required: true
      param :agency, Hash do
        param :name, String, required: true
        param :email, String, required: true
        param :avatar, String, 'File or base64', required: false
        param :phone, String, required: false
        param :manager_id, Integer, 'Manager ID', required: true
        param :town_manager_id, Integer, 'Town Manager ID', required: true
        param :status, Agency.statuses.keys, 'Default: active', required: false
        param :officer_ids, Array, 'Array of officer IDs', required: false
        param :location, Hash, 'Geolocation params', required: true do
          param :city, String, required: true
          param :street, String, required: true
          param :building, String, required: true
          param :country, String, required: true
          param :zip, String, required: true
          param :lng, :number, required: true
          param :ltd, :number, required: true
        end
      end

      def create
        authorize! Agency
        payload = params.fetch(:agency, {}).merge(current_user: current_user)
        result = Agencies::Create.run(payload)
        respond_with result, serializer: ::Api::Dashboard::DetailedAgencySerializer
      end

      api :PUT, '/api/dashboard/agencies/:id', 'Update agency (specify fields only we want to update)'
      header :Authorization, 'Auth token', required: true
      param :id, Integer, 'Agency to update ID'
      param :agency, Hash do
        param :name, String, required: false
        param :email, String, required: false
        param :phone, String, required: false
        param :avatar, String, 'File or base64', required: false
        param :manager_id, Integer, 'Manager ID', required: false
        param :town_manager_id, Integer, 'Town Manager ID', required: true
        param :status, Agency.statuses.keys, 'Default: active', required: false
        param :officer_ids, Array, 'Array of officer IDs', required: false
        param :location, Hash, 'Geolocation params', required: false do
          param :city, String, required: true
          param :street, String, required: true
          param :building, String, required: true
          param :country, String, required: true
          param :zip, String, required: true
          param :lng, :number, required: true
          param :ltd, :number, required: true
        end
      end

      def update
        agency = Agency.find(params[:id])
        authorize! agency
        payload = params.fetch(:agency, {}).merge(current_user: current_user, agency: agency)
        result = ::Agencies::Update.run(payload)
        respond_with result, serializer: ::Api::Dashboard::DetailedAgencySerializer
      end

      api :GET, '/api/dashboard/agencies/search', 'Search for active agencies'
      header :Authorization, 'Auth token', required: true
      param :query, String, 'Query (can be substring of name, full address, email or phone)', required: true

      def search
        authorize! Agency
        scope = paginate AgenciesQuery.call(params.merge(user: current_user))
        respond_with scope, each_serializer: ::Api::Dashboard::AgencySerializer
      end

      api :GET, "/api/dashboard/agencies/:id", 'Get agency by ID'
      param :id, Integer, 'Agency id', required: true
      header :Authorization, 'Auth token', required: true

      def show
        agency = Agency.find(params[:id])
        authorize! agency
        respond_with agency, serializer: ::Api::Dashboard::DetailedAgencySerializer
      end

    end
  end
end
